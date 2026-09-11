pub mod api;
mod frb_generated;

use image::codecs::jpeg::JpegEncoder;
use image::codecs::png::{CompressionType, FilterType, PngEncoder};
use image::{ColorType, DynamicImage, ImageEncoder, ImageFormat, ImageReader};
use std::fs;
use std::io::{BufReader, BufWriter, Read, Seek, SeekFrom, Write};
use std::path::{Path, PathBuf};
use std::time::Instant;
use thiserror::Error;

#[allow(unused_imports)]
use log::{debug, error, info, warn};

// ─── Core Error Type ──────────────────────────────────────────────────────────

#[derive(Debug, Error)]
pub enum ImageEngineError {
    #[error("unsupported image input format")]
    UnsupportedInput,
    #[error("failed to decode image: {0}")]
    Decode(String),
    #[error("failed to encode image: {0}")]
    Encode(String),
    #[error("io error: {0}")]
    Io(#[from] std::io::Error),
    #[error("image processing error: {0}")]
    Image(#[from] image::ImageError),
}

// ─── Public API Types (internal) ──────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InternalOutputFormat {
    Jpeg,
    Png,
    Webp,
    Auto,
}

#[derive(Debug, Clone)]
pub enum InternalResizeMode {
    None,
    MaxLongEdge { value: u32 },
    ExactSize {
        width: u32,
        height: u32,
        keep_aspect_ratio: bool,
    },
    ScalePercentage { percentage: f32 },
}

#[derive(Debug, Clone)]
pub struct InternalCompressionRequest {
    pub input_path: PathBuf,
    pub output_path: PathBuf,
    pub quality: u8,
    pub png_level: u8,
    pub resize_mode: InternalResizeMode,
    pub output_format: InternalOutputFormat,
    pub target_size_bytes: Option<u64>,
}

#[derive(Debug, Clone)]
pub struct InternalCompressionResponse {
    pub output_path: PathBuf,
    pub original_bytes: u64,
    pub compressed_bytes: u64,
    pub width: u32,
    pub height: u32,
    pub format: String,
}

// ─── I/O Buffer Tuning ────────────────────────────────────────────────────────
// 256 KB read buffer: large images (4–20 MB) benefit from fewer syscalls.
// Write buffer matches: encoder flushes in large chunks.
const READ_BUFFER: usize = 256 * 1024;
const WRITE_BUFFER: usize = 256 * 1024;

// ─── Core Compression Pipeline ────────────────────────────────────────────────

pub fn compress_image_internal(
    request: &InternalCompressionRequest,
) -> Result<InternalCompressionResponse, ImageEngineError> {
    let pipeline_start = Instant::now();
    let file_name = request
        .input_path
        .file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_else(|| request.input_path.to_string_lossy().into_owned());

    // [1/6] Stat
    let original_bytes = fs::metadata(&request.input_path)?.len();
    info!(
        "[compress] START file={} original_size={} bytes",
        file_name, original_bytes
    );

    // [2/6] Open + format detection
    let t = Instant::now();
    let mut input_file = fs::File::open(&request.input_path)?;
    let format = detect_format_with_magic_bytes(&mut input_file, &request.input_path)?;
    info!(
        "[compress] FORMAT_DETECT file={} detected={:?} elapsed={}us",
        file_name,
        format,
        t.elapsed().as_micros()
    );

    // [3/6] Decode
    let t = Instant::now();
    input_file.seek(SeekFrom::Start(0))?;
    let buffered_reader = BufReader::with_capacity(READ_BUFFER, input_file);
    let image = ImageReader::with_format(buffered_reader, format)
        .decode()
        .map_err(|e| {
            error!("[compress] DECODE_FAILED file={} error={}", file_name, e);
            ImageEngineError::Decode(e.to_string())
        })?;
    info!(
        "[compress] DECODE file={} dims={}x{} color={:?} elapsed={}ms",
        file_name,
        image.width(),
        image.height(),
        image.color(),
        t.elapsed().as_millis()
    );

    // [4/6] Color space + resize
    let has_alpha = image.color().has_alpha();
    let target_format = resolve_target_format(request.output_format, format, has_alpha);
    let pre_converted = pre_convert_image(image, target_format);

    let pre_resize_w = pre_converted.width();
    let pre_resize_h = pre_converted.height();
    let t = Instant::now();
    let pre_converted = apply_resize_preconverted(pre_converted, &request.resize_mode);
    let final_width = pre_converted.width();
    let final_height = pre_converted.height();
    if pre_resize_w != final_width || pre_resize_h != final_height {
        info!(
            "[compress] RESIZE file={} from={}x{} to={}x{} mode={:?} elapsed={}ms",
            file_name,
            pre_resize_w,
            pre_resize_h,
            final_width,
            final_height,
            request.resize_mode,
            t.elapsed().as_millis()
        );
    }

    // [5/6] Encode (Zero-Copy Borrowed Encoders)
    if let Some(parent) = request.output_path.parent() {
        fs::create_dir_all(parent)?;
    }

    let t = Instant::now();
    let (mut encoded_bytes, mut resolved_fmt) = if let Some(target_bytes) = request.target_size_bytes {
        if target_bytes > 0 && original_bytes > target_bytes {
            info!(
                "[compress] TARGET_SIZE mode active file={} target={}B",
                file_name, target_bytes
            );
            optimize_to_target_size(
                &pre_converted,
                target_format,
                request.png_level,
                target_bytes,
                has_alpha,
            )?
        } else {
            let buf = encode_to_bytes(
                &pre_converted,
                target_format,
                request.quality,
                request.png_level,
            )?;
            (buf, target_format)
        }
    } else {
        let mut buf = encode_to_bytes(
            &pre_converted,
            target_format,
            request.quality,
            request.png_level,
        )?;
        let mut current_fmt = target_format;

        // GUARANTEED SIZE REDUCTION: If encoded output is larger than original file, optimize!
        if buf.len() as u64 >= original_bytes {
            info!("[compress] Size guard triggered for file={}: encoded ({}B) >= original ({}B), optimizing...", file_name, buf.len(), original_bytes);
            let webp_buf = encode_to_bytes(&pre_converted, InternalOutputFormat::Webp, 75, request.png_level)?;
            if (webp_buf.len() as u64) < original_bytes {
                buf = webp_buf;
                current_fmt = InternalOutputFormat::Webp;
            } else {
                let lower_q = (request.quality.saturating_sub(20)).max(50);
                let jpeg_buf = encode_to_bytes(&pre_converted, InternalOutputFormat::Jpeg, lower_q, request.png_level)?;
                if (jpeg_buf.len() as u64) < original_bytes {
                    buf = jpeg_buf;
                    current_fmt = InternalOutputFormat::Jpeg;
                }
            }
        }
        (buf, current_fmt)
    };

    // Absolute fallback: If output is still larger than original, copy original
    if encoded_bytes.len() as u64 >= original_bytes
        && matches!(request.resize_mode, InternalResizeMode::None)
    {
        info!("[compress] Fallback copy original file={} (guaranteeing <= original size)", file_name);
        fs::copy(&request.input_path, &request.output_path)?;
        encoded_bytes = fs::read(&request.output_path)?;
        resolved_fmt = match format {
            ImageFormat::Png => InternalOutputFormat::Png,
            ImageFormat::WebP => InternalOutputFormat::Webp,
            _ => InternalOutputFormat::Jpeg,
        };
    } else {
        let output_file = fs::File::create(&request.output_path)?;
        let mut buffered_writer = BufWriter::with_capacity(WRITE_BUFFER, output_file);
        buffered_writer.write_all(&encoded_bytes)?;
        buffered_writer.flush()?;
    }

    let encode_ms = t.elapsed().as_millis();
    let compressed_bytes = encoded_bytes.len() as u64;
    let savings_pct = if original_bytes > 0 {
        100.0 - (compressed_bytes as f64 / original_bytes as f64 * 100.0)
    } else {
        0.0
    };

    let format_str = match resolved_fmt {
        InternalOutputFormat::Jpeg => "jpeg",
        InternalOutputFormat::Png => "png",
        InternalOutputFormat::Webp => "webp",
        InternalOutputFormat::Auto => "jpeg",
    }
    .to_string();

    info!(
        "[compress] DONE file={} format={} dims={}x{} original={}B compressed={}B saved={:.1}% encode={}ms total={}ms",
        file_name,
        format_str,
        final_width,
        final_height,
        original_bytes,
        compressed_bytes,
        savings_pct,
        encode_ms,
        pipeline_start.elapsed().as_millis()
    );

    Ok(InternalCompressionResponse {
        output_path: request.output_path.clone(),
        original_bytes,
        compressed_bytes,
        width: final_width,
        height: final_height,
        format: format_str,
    })
}

// ─── Format Detection (Magic Bytes) ───────────────────────────────────────────

fn detect_format_with_magic_bytes(
    file: &mut fs::File,
    path: &Path,
) -> Result<ImageFormat, ImageEngineError> {
    let mut header = [0u8; 12];
    let bytes_read = file.read(&mut header).unwrap_or(0);

    // JPEG: FF D8 FF
    if bytes_read >= 3 && header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF {
        return Ok(ImageFormat::Jpeg);
    }

    // PNG: 89 50 4E 47 0D 0A 1A 0A
    if bytes_read >= 8
        && header[0] == 0x89
        && header[1] == 0x50
        && header[2] == 0x4E
        && header[3] == 0x47
        && header[4] == 0x0D
        && header[5] == 0x0A
        && header[6] == 0x1A
        && header[7] == 0x0A
    {
        return Ok(ImageFormat::Png);
    }

    // WebP: RIFF....WEBP
    if bytes_read >= 12 && &header[0..4] == b"RIFF" && &header[8..12] == b"WEBP" {
        return Ok(ImageFormat::WebP);
    }

    // Extension fallback
    match path
        .extension()
        .and_then(|v| v.to_str())
        .map(|v| v.to_ascii_lowercase())
        .as_deref()
    {
        Some("jpg") | Some("jpeg") => Ok(ImageFormat::Jpeg),
        Some("png") => Ok(ImageFormat::Png),
        Some("webp") => Ok(ImageFormat::WebP),
        _ => Err(ImageEngineError::UnsupportedInput),
    }
}

// ─── Target Format Resolution ─────────────────────────────────────────────────

#[inline(always)]
fn resolve_target_format(
    output_format: InternalOutputFormat,
    input_format: ImageFormat,
    has_alpha: bool,
) -> InternalOutputFormat {
    match output_format {
        InternalOutputFormat::Auto => match input_format {
            ImageFormat::Png => {
                if has_alpha {
                    InternalOutputFormat::Webp
                } else {
                    InternalOutputFormat::Jpeg
                }
            }
            ImageFormat::WebP => InternalOutputFormat::Webp,
            _ => InternalOutputFormat::Jpeg,
        },
        other => other,
    }
}

// ─── Pre-Convert Image (Zero Copy Buffer Management) ──────────────────────────

pub enum PreConvertedImage {
    Rgb { width: u32, height: u32, data: Vec<u8> },
    Rgba { width: u32, height: u32, data: Vec<u8> },
}

impl PreConvertedImage {
    #[inline(always)]
    pub fn width(&self) -> u32 {
        match self {
            Self::Rgb { width, .. } => *width,
            Self::Rgba { width, .. } => *width,
        }
    }

    #[inline(always)]
    pub fn height(&self) -> u32 {
        match self {
            Self::Rgb { height, .. } => *height,
            Self::Rgba { height, .. } => *height,
        }
    }
}

#[inline(always)]
fn pre_convert_image(image: DynamicImage, target: InternalOutputFormat) -> PreConvertedImage {
    let (w, h) = (image.width(), image.height());
    match target {
        InternalOutputFormat::Jpeg => {
            let rgb = image.into_rgb8();
            PreConvertedImage::Rgb {
                width: w,
                height: h,
                data: rgb.into_raw(),
            }
        }
        InternalOutputFormat::Png | InternalOutputFormat::Webp | InternalOutputFormat::Auto => {
            if image.color().has_alpha() {
                let rgba = image.into_rgba8();
                PreConvertedImage::Rgba {
                    width: w,
                    height: h,
                    data: rgba.into_raw(),
                }
            } else {
                let rgb = image.into_rgb8();
                PreConvertedImage::Rgb {
                    width: w,
                    height: h,
                    data: rgb.into_raw(),
                }
            }
        }
    }
}

// ─── Resize ───────────────────────────────────────────────────────────────────

use fast_image_resize as fr;

fn apply_resize_preconverted(
    img: PreConvertedImage,
    mode: &InternalResizeMode,
) -> PreConvertedImage {
    let (width, height) = (img.width(), img.height());
    if width == 0 || height == 0 {
        return img;
    }

    let (next_width, next_height) = match mode {
        InternalResizeMode::None => return img,
        InternalResizeMode::MaxLongEdge { value } => {
            let max_long = *value;
            let long_edge = width.max(height);
            if long_edge <= max_long {
                return img;
            }
            let scale = max_long as f64 / long_edge as f64;
            (
                ((width as f64 * scale).round() as u32).max(1),
                ((height as f64 * scale).round() as u32).max(1),
            )
        }
        InternalResizeMode::ExactSize {
            width: tw,
            height: th,
            keep_aspect_ratio,
        } => {
            let target_w = (*tw).max(1);
            let target_h = (*th).max(1);
            if *keep_aspect_ratio {
                let scale = (target_w as f64 / width as f64).min(target_h as f64 / height as f64);
                (
                    ((width as f64 * scale).round() as u32).max(1),
                    ((height as f64 * scale).round() as u32).max(1),
                )
            } else {
                (target_w, target_h)
            }
        }
        InternalResizeMode::ScalePercentage { percentage } => {
            let scale = (*percentage as f64 / 100.0).max(0.01);
            (
                ((width as f64 * scale).round() as u32).max(1),
                ((height as f64 * scale).round() as u32).max(1),
            )
        }
    };

    if next_width == width && next_height == height {
        return img;
    }

    let (pixel_type, mut src_bytes) = match img {
        PreConvertedImage::Rgb { data, .. } => (fr::PixelType::U8x3, data),
        PreConvertedImage::Rgba { data, .. } => (fr::PixelType::U8x4, data),
    };

    let src_image = match fr::images::Image::from_slice_u8(width, height, &mut src_bytes, pixel_type) {
        Ok(i) => i,
        Err(_) => {
            return match pixel_type {
                fr::PixelType::U8x3 => PreConvertedImage::Rgb { width, height, data: src_bytes },
                _ => PreConvertedImage::Rgba { width, height, data: src_bytes },
            };
        }
    };

    let mut dst_image = fr::images::Image::new(next_width, next_height, pixel_type);
    let mut resizer = fr::Resizer::new();
    let options = fr::ResizeOptions::new().resize_alg(fr::ResizeAlg::Convolution(fr::FilterType::CatmullRom));

    if resizer.resize(&src_image, &mut dst_image, &options).is_err() {
        return match pixel_type {
            fr::PixelType::U8x3 => PreConvertedImage::Rgb { width, height, data: src_bytes },
            _ => PreConvertedImage::Rgba { width, height, data: src_bytes },
        };
    }

    let buffer = dst_image.into_vec();
    match pixel_type {
        fr::PixelType::U8x3 => PreConvertedImage::Rgb {
            width: next_width,
            height: next_height,
            data: buffer,
        },
        _ => PreConvertedImage::Rgba {
            width: next_width,
            height: next_height,
            data: buffer,
        },
    }
}

// ─── Encoders (Zero-Copy Borrowed Memory Execution) ───────────────────────────

fn encode_to_bytes(
    img: &PreConvertedImage,
    target_format: InternalOutputFormat,
    quality: u8,
    png_level: u8,
) -> Result<Vec<u8>, ImageEngineError> {
    let mut buf = Vec::with_capacity(256 * 1024);
    match target_format {
        InternalOutputFormat::Jpeg => {
            encode_jpeg_ref(img, quality, &mut buf)?;
        }
        InternalOutputFormat::Png => {
            encode_png_ref(img, png_level, &mut buf)?;
        }
        InternalOutputFormat::Webp => {
            encode_webp_ref(img, quality, &mut buf)?;
        }
        InternalOutputFormat::Auto => {
            encode_jpeg_ref(img, quality, &mut buf)?;
        }
    }
    Ok(buf)
}

fn encode_jpeg_ref<W: Write>(
    img: &PreConvertedImage,
    quality: u8,
    writer: &mut W,
) -> Result<(), ImageEngineError> {
    let encoder = JpegEncoder::new_with_quality(writer, quality);
    match img {
        PreConvertedImage::Rgb { width, height, data } => {
            encoder
                .write_image(data, *width, *height, ColorType::Rgb8.into())
                .map_err(|e| ImageEngineError::Encode(e.to_string()))?;
        }
        PreConvertedImage::Rgba { width, height, data } => {
            // Strip alpha on the fly
            let mut rgb_data = Vec::with_capacity((width * height * 3) as usize);
            for chunk in data.chunks_exact(4) {
                rgb_data.push(chunk[0]);
                rgb_data.push(chunk[1]);
                rgb_data.push(chunk[2]);
            }
            encoder
                .write_image(&rgb_data, *width, *height, ColorType::Rgb8.into())
                .map_err(|e| ImageEngineError::Encode(e.to_string()))?;
        }
    }
    Ok(())
}

fn encode_png_ref<W: Write>(
    img: &PreConvertedImage,
    png_level: u8,
    writer: &mut W,
) -> Result<(), ImageEngineError> {
    let (compression, filter) = match png_level {
        0..=3 => (CompressionType::Fast, FilterType::Sub),
        4..=6 => (CompressionType::Default, FilterType::Sub),
        _ => (CompressionType::Best, FilterType::Adaptive),
    };
    let encoder = PngEncoder::new_with_quality(writer, compression, filter);

    match img {
        PreConvertedImage::Rgb { width, height, data } => {
            encoder
                .write_image(data, *width, *height, ColorType::Rgb8.into())
                .map_err(|e| ImageEngineError::Encode(e.to_string()))?;
        }
        PreConvertedImage::Rgba { width, height, data } => {
            encoder
                .write_image(data, *width, *height, ColorType::Rgba8.into())
                .map_err(|e| ImageEngineError::Encode(e.to_string()))?;
        }
    }
    Ok(())
}

fn encode_webp_ref<W: Write>(
    img: &PreConvertedImage,
    quality: u8,
    writer: &mut W,
) -> Result<(), ImageEngineError> {
    let (width, height) = (img.width(), img.height());
    let encoder = match img {
        PreConvertedImage::Rgb { data, .. } => webp::Encoder::from_rgb(data, width, height),
        PreConvertedImage::Rgba { data, .. } => webp::Encoder::from_rgba(data, width, height),
    };

    let webp_data = if quality >= 100 {
        encoder.encode_lossless()
    } else {
        encoder.encode(quality as f32)
    };

    writer
        .write_all(&webp_data)
        .map_err(|e| ImageEngineError::Encode(e.to_string()))?;
    Ok(())
}

// ─── Adaptive Multi-Tier Target Size Optimizer ─────────────────────────────────

fn optimize_to_target_size(
    img: &PreConvertedImage,
    initial_format: InternalOutputFormat,
    png_level: u8,
    target_bytes: u64,
    has_alpha: bool,
) -> Result<(Vec<u8>, InternalOutputFormat), ImageEngineError> {
    let mut current_format = initial_format;

    // Step 1: Auto-switch format if PNG is requested (PNG is lossless and cannot fit tight size targets)
    if current_format == InternalOutputFormat::Png || current_format == InternalOutputFormat::Auto {
        current_format = if has_alpha {
            InternalOutputFormat::Webp
        } else {
            InternalOutputFormat::Jpeg
        };
    }

    // Attempt 1: 8-Iteration Precision Binary Search on Quality
    if let Some((buf, fmt)) = binary_search_quality(img, current_format, png_level, target_bytes)? {
        return Ok((buf, fmt));
    }

    // Attempt 2: If JPEG failed at minimum quality, switch to WebP (30-50% superior compression density)
    if current_format == InternalOutputFormat::Jpeg {
        current_format = InternalOutputFormat::Webp;
        if let Some((buf, fmt)) = binary_search_quality(img, current_format, png_level, target_bytes)? {
            return Ok((buf, fmt));
        }
    }

    // Attempt 3: Iterative SIMD Resolution Downscaling using fast_image_resize
    let test_buf = encode_to_bytes(img, current_format, 15, png_level)?;
    let ref_bytes = (test_buf.len() as u64).max(1);

    // Compute estimated 2D scale factor based on area ratio
    let mut scale_factor = ((target_bytes as f64 / ref_bytes as f64).sqrt() * 0.95).clamp(0.05, 0.90);
    let mut last_scaled_img: Option<PreConvertedImage> = None;

    for _ in 0..4 {
        let resize_mode = InternalResizeMode::ScalePercentage {
            percentage: (scale_factor * 100.0) as f32,
        };

        let scaled_img = match img {
            PreConvertedImage::Rgb { width, height, data } => {
                apply_resize_preconverted(
                    PreConvertedImage::Rgb { width: *width, height: *height, data: data.clone() },
                    &resize_mode,
                )
            }
            PreConvertedImage::Rgba { width, height, data } => {
                apply_resize_preconverted(
                    PreConvertedImage::Rgba { width: *width, height: *height, data: data.clone() },
                    &resize_mode,
                )
            }
        };

        if let Some((buf, fmt)) = binary_search_quality(&scaled_img, current_format, png_level, target_bytes)? {
            return Ok((buf, fmt));
        }

        last_scaled_img = Some(scaled_img);
        scale_factor *= 0.65;
        if scale_factor < 0.02 {
            break;
        }
    }

    // Strict Target Size Enforcer Guard: Absolute fallback at low quality & resolution
    let fallback_img = last_scaled_img.as_ref().unwrap_or(img);
    let buf = encode_to_bytes(fallback_img, current_format, 1, png_level)?;
    Ok((buf, current_format))
}

fn binary_search_quality(
    img: &PreConvertedImage,
    target_format: InternalOutputFormat,
    png_level: u8,
    target_bytes: u64,
) -> Result<Option<(Vec<u8>, InternalOutputFormat)>, ImageEngineError> {
    let mut low = 1u8;
    let mut high = 98u8;
    let mut best_bytes: Option<Vec<u8>> = None;

    // 8-step binary search: 2^8 = 256 states -> precision down to single integer quality
    for _ in 0..8 {
        let q = ((low as u16 + high as u16) / 2) as u8;
        let buf = encode_to_bytes(img, target_format, q, png_level)?;
        let len = buf.len() as u64;

        if len <= target_bytes {
            best_bytes = Some(buf);
            low = q + 1;
        } else {
            high = q.saturating_sub(1);
        }

        if low > high {
            break;
        }
    }

    if let Some(buf) = best_bytes {
        Ok(Some((buf, target_format)))
    } else {
        Ok(None)
    }
}


