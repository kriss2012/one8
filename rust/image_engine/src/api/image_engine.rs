use std::path::PathBuf;
use std::sync::OnceLock;
use std::time::Instant;
use rayon::{prelude::*, ThreadPool, ThreadPoolBuilder};
use crate::frb_generated::StreamSink;
use crate::compress_image_internal;

#[allow(unused_imports)]
use log::{debug, error, info, warn};

// ─── Logger Init ──────────────────────────────────────────────────────────────
// android_logger routes Rust log:: calls to Android logcat under tag="one8".
// On non-Android targets, the log facade is a no-op unless another backend is set.

static LOGGER_INIT: OnceLock<()> = OnceLock::new();

fn init_logger() {
    LOGGER_INIT.get_or_init(|| {
        #[cfg(target_os = "android")]
        android_logger::init_once(
            android_logger::Config::default()
                .with_tag("one8")
                .with_max_level(log::LevelFilter::Debug),
        );
    });
}

// ─── Enums & Public Structs ────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy)]
pub enum OutputFormat {
    Jpeg,
    Png,
    Webp,
    Auto,
}

#[derive(Debug, Clone)]
pub enum ResizeMode {
    None,
    MaxLongEdge { value: u32 },
    ExactSize { width: u32, height: u32, keep_aspect_ratio: bool },
    ScalePercentage { percentage: f32 },
}

#[derive(Debug, Clone)]
pub struct CompressionRequest {
    pub id: String,
    pub input_path: String,
    pub output_path: String,
    pub quality: u8,
    pub png_level: u8,
    pub resize_mode: ResizeMode,
    pub output_format: OutputFormat,
    pub target_size_bytes: Option<u64>,
}

/// NOTE: field order MUST match frb_generated.rs SseDecode/SseEncode exactly.
#[derive(Debug, Clone)]
pub struct CompressionResponse {
    pub id: String,
    pub output_path: String,
    pub original_bytes: u64,
    pub compressed_bytes: u64,
    pub width: u32,
    pub height: u32,
    pub format: String,
}

#[derive(Debug, Clone)]
pub struct CompressionTaskProgress {
    pub id: String,
    pub success: bool,
    pub response: Option<CompressionResponse>,
    pub error: Option<String>,
}

// ─── Singleton Compression Thread Pool ────────────────────────────────────────
// Created once, reused for every compression session.
// Pinned to (num_cpus - 1) threads to never starve the Flutter UI thread.
// On a 4-core phone: 3 workers. On a 2-core: 1 worker. On 8-core: 7 workers.

static COMPRESSION_POOL: OnceLock<ThreadPool> = OnceLock::new();

fn get_compression_pool() -> &'static ThreadPool {
    init_logger();
    COMPRESSION_POOL.get_or_init(|| {
        let num_threads = (num_cpus::get().saturating_sub(1)).max(1);
        info!(
            "[pool] Initializing Rayon compression pool: threads={} (total_cpus={})",
            num_threads,
            num_cpus::get()
        );
        ThreadPoolBuilder::new()
            .num_threads(num_threads)
            // 8 MB stack per worker: image decode is stack-heavy
            .stack_size(8 * 1024 * 1024)
            .thread_name(|i| format!("one8-{i}"))
            .build()
            .unwrap_or_else(|e| {
                warn!("[pool] Failed to build pinned pool ({}), falling back to defaults", e);
                ThreadPoolBuilder::new().build().expect("Failed to build fallback pool")
            })
    })
}

// ─── Internal Request Builder ─────────────────────────────────────────────────

fn to_internal_request(request: &CompressionRequest) -> crate::InternalCompressionRequest {
    crate::InternalCompressionRequest {
        input_path: PathBuf::from(&request.input_path),
        output_path: PathBuf::from(&request.output_path),
        quality: quality_clamp(request.quality),
        png_level: request.png_level.min(9),
        resize_mode: match &request.resize_mode {
            ResizeMode::None => crate::InternalResizeMode::None,
            ResizeMode::MaxLongEdge { value } => crate::InternalResizeMode::MaxLongEdge { value: *value },
            ResizeMode::ExactSize { width, height, keep_aspect_ratio } => {
                crate::InternalResizeMode::ExactSize {
                    width: *width,
                    height: *height,
                    keep_aspect_ratio: *keep_aspect_ratio,
                }
            }
            ResizeMode::ScalePercentage { percentage } => {
                crate::InternalResizeMode::ScalePercentage { percentage: *percentage }
            }
        },
        output_format: match request.output_format {
            OutputFormat::Jpeg => crate::InternalOutputFormat::Jpeg,
            OutputFormat::Png => crate::InternalOutputFormat::Png,
            OutputFormat::Webp => crate::InternalOutputFormat::Webp,
            OutputFormat::Auto => crate::InternalOutputFormat::Auto,
        },
        target_size_bytes: request.target_size_bytes,
    }
}

// ─── Public API ───────────────────────────────────────────────────────────────

/// Single-image synchronous compression. Used as fallback and for single images.
pub fn compress_image(request: CompressionRequest) -> Result<CompressionResponse, String> {
    init_logger();
    let req_id = request.id.clone();
    let file_name = std::path::Path::new(&request.input_path)
        .file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_else(|| request.input_path.clone());
    info!("[api] compress_image START id={} file={} quality={} format={:?}", req_id, file_name, request.quality, request.output_format);
    let t = Instant::now();
    let internal = to_internal_request(&request);
    let response = compress_image_internal(&internal).map_err(|e| {
        error!("[api] compress_image FAILED id={} file={} error={}", req_id, file_name, e);
        e.to_string()
    })?;
    info!("[api] compress_image DONE id={} file={} elapsed={}ms", req_id, file_name, t.elapsed().as_millis());
    Ok(CompressionResponse {
        id: req_id,
        output_path: response.output_path.to_string_lossy().into_owned(),
        original_bytes: response.original_bytes,
        compressed_bytes: response.compressed_bytes,
        width: response.width,
        height: response.height,
        format: response.format,
    })
}

/// Batch compression using the singleton Rayon thread pool.
/// Required by frb_generated.rs — kept for API compatibility.
pub fn compress_images_batch(
    requests: Vec<CompressionRequest>,
) -> Vec<Option<CompressionResponse>> {
    let pool = get_compression_pool();
    pool.install(|| {
        requests
            .into_par_iter()
            .map(|req| compress_image(req).ok())
            .collect()
    })
}

/// Streaming batch compression using the singleton Rayon thread pool.
pub fn compress_images_stream(
    requests: Vec<CompressionRequest>,
    sink: StreamSink<CompressionTaskProgress>,
) {
    let total = requests.len();
    let pool = get_compression_pool();
    info!("[api] compress_images_stream START total_images={} pool_threads={}", total, pool.current_num_threads());
    let batch_start = Instant::now();

    pool.install(|| {
        requests.into_par_iter().for_each(|req| {
            let req_id = req.id.clone();
            let file_name = std::path::Path::new(&req.input_path)
                .file_name()
                .map(|n| n.to_string_lossy().into_owned())
                .unwrap_or_else(|| req.input_path.clone());
            let internal = to_internal_request(&req);
            let t = Instant::now();

            match compress_image_internal(&internal) {
                Ok(resp) => {
                    let elapsed = t.elapsed().as_millis();
                    let savings_pct = if resp.original_bytes > 0 {
                        100.0 - (resp.compressed_bytes as f64 / resp.original_bytes as f64 * 100.0)
                    } else {
                        0.0
                    };
                    info!(
                        "[api] stream_item OK id={} file={} saved={:.1}% elapsed={}ms",
                        req_id, file_name, savings_pct, elapsed
                    );
                    let _ = sink.add(CompressionTaskProgress {
                        id: req_id.clone(),
                        success: true,
                        response: Some(CompressionResponse {
                            id: req_id,
                            output_path: resp.output_path.to_string_lossy().into_owned(),
                            original_bytes: resp.original_bytes,
                            compressed_bytes: resp.compressed_bytes,
                            width: resp.width,
                            height: resp.height,
                            format: resp.format,
                        }),
                        error: None,
                    });
                }
                Err(err) => {
                    error!(
                        "[api] stream_item FAILED id={} file={} elapsed={}ms error={}",
                        req_id, file_name, t.elapsed().as_millis(), err
                    );
                    let _ = sink.add(CompressionTaskProgress {
                        id: req_id,
                        success: false,
                        response: None,
                        error: Some(err.to_string()),
                    });
                }
            }
        });
    });

    info!(
        "[api] compress_images_stream DONE total_images={} total_elapsed={}ms",
        total, batch_start.elapsed().as_millis()
    );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

#[inline(always)]
fn quality_clamp(q: u8) -> u8 {
    match q {
        0 => 80,
        1..=100 => q,
        _ => 100,
    }
}
