import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/app_log.dart';
import '../../../../src/rust/api/image_engine.dart' as frb;
import '../../domain/entities/compressed_image.dart';
import '../../domain/entities/compression_preset.dart';
import '../../domain/entities/compression_task_update.dart';
import '../../domain/entities/selected_image.dart';
import 'image_engine_data_source.dart';
import 'native_image_engine_bridge.dart';

class RustFfiImageEngineDataSource implements ImageEngineDataSource {
  RustFfiImageEngineDataSource({required this.fallbackDataSource});

  final ImageEngineDataSource fallbackDataSource;
  static const _bridge = NativeImageEngineBridge.instance;
  static const _tag = 'DataSource';

  static bool isSupportedPlatform() => _bridge.isSupportedPlatform;

  @override
  Future<CompressedImage> compressImage({
    required SelectedImage image,
    required CompressionPreset preset,
  }) async {
    AppLog.info(_tag, 'compressImage() file=${image.fileName} format=${image.format} quality=${preset.quality}');

    if (image.format == SupportedImageFormat.unsupported) {
      AppLog.warn(_tag, 'compressImage() unsupported format for file=${image.fileName}');
      throw const AppFailure('Unsupported image format. Supports JPEG, PNG, and WebP.');
    }

    if (!_bridge.isAvailable) {
      AppLog.warn(_tag, 'compressImage() native bridge not available — routing to fallback engine');
      return fallbackDataSource.compressImage(image: image, preset: preset);
    }

    final outputDirectory = await Directory.systemTemp.createTemp('one8');
    final ext = _resolveExtension(image.format, preset.targetFormat);
    final fileNameWithoutExt = path.basenameWithoutExtension(image.fileName);
    final outputFileName = '${fileNameWithoutExt}_compressed$ext';
    final outputPath = path.join(outputDirectory.path, outputFileName);

    AppLog.info(_tag, 'compressImage() output_path=$outputPath');

    try {
      final result = await _bridge.compress(
        id: image.path,
        inputPath: image.path,
        outputPath: outputPath,
        quality: preset.quality,
        pngLevel: preset.pngLevel,
        resizeMode: _mapResizeMode(preset.resizeMode),
        outputFormat: _mapOutputFormat(image.format, preset.targetFormat),
        targetSizeBytes: preset.targetSizeBytes != null ? BigInt.from(preset.targetSizeBytes!) : null,
      );
      var finalOutputPath = result.outputPath;
      final actualExt = '.${result.format}';
      if (path.extension(finalOutputPath) != actualExt) {
        final newPath = path.join(
          path.dirname(finalOutputPath),
          '${path.basenameWithoutExtension(finalOutputPath)}$actualExt',
        );
        AppLog.info(_tag, 'compressImage() renamed output from $finalOutputPath to $newPath due to size guard format change');
        final file = File(finalOutputPath);
        if (await file.exists()) {
          await file.rename(newPath);
        }
        finalOutputPath = newPath;
      }

      AppLog.info(
        _tag,
        'compressImage() OK file=${image.fileName} '
        'original=${result.originalBytes}B compressed=${result.compressedBytes}B '
        'dims=${result.width}x${result.height}',
      );

      return CompressedImage(
        source: image,
        outputPath: finalOutputPath,
        outputFileName: path.basename(finalOutputPath),
        originalBytes: result.originalBytes,
        compressedBytes: result.compressedBytes,
      );
    } catch (e, st) {
      AppLog.warn(_tag, 'compressImage() native FAILED for file=${image.fileName} error=$e — falling back to raster engine');
      AppLog.debug(_tag, 'compressImage() fallback stacktrace: $st');
      return fallbackDataSource.compressImage(image: image, preset: preset);
    }
  }

  @override
  Stream<CompressionTaskUpdate> compressBatchStream({
    required List<SelectedImage> images,
    required CompressionPreset preset,
  }) async* {
    AppLog.info(
      _tag,
      'compressBatchStream() START total=${images.length} '
      'preset=${preset.id} quality=${preset.quality} pngLevel=${preset.pngLevel} '
      'targetFormat=${preset.targetFormat} resizeMode=${preset.resizeMode}',
    );

    if (!_bridge.isAvailable) {
      AppLog.warn(_tag, 'compressBatchStream() native bridge not available — routing all to fallback engine');
      yield* fallbackDataSource.compressBatchStream(images: images, preset: preset);
      return;
    }

    final outputDirectory = await Directory.systemTemp.createTemp('one8_batch');
    AppLog.info(_tag, 'compressBatchStream() output_dir=${outputDirectory.path}');

    final imageMap = <String, SelectedImage>{};
    final requests = <frb.CompressionRequest>[];

    for (var i = 0; i < images.length; i++) {
      final img = images[i];
      final id = '${img.path}_$i';
      imageMap[id] = img;

      final ext = _resolveExtension(img.format, preset.targetFormat);
      final fileNameWithoutExt = path.basenameWithoutExtension(img.fileName);
      final outputFileName = '${fileNameWithoutExt}_compressed$ext';
      final outputPath = path.join(outputDirectory.path, outputFileName);

      AppLog.debug(_tag, 'compressBatchStream() enqueue[$i] id=$id file=${img.fileName} -> $outputPath');

      requests.add(
        frb.CompressionRequest(
          id: id,
          inputPath: img.path,
          outputPath: outputPath,
          quality: preset.quality,
          pngLevel: preset.pngLevel,
          resizeMode: _mapResizeMode(preset.resizeMode),
          outputFormat: _mapOutputFormat(img.format, preset.targetFormat),
          targetSizeBytes: preset.targetSizeBytes != null ? BigInt.from(preset.targetSizeBytes!) : null,
        ),
      );
    }

    AppLog.info(_tag, 'compressBatchStream() dispatching ${requests.length} requests to Rust FFI stream');
    final batchSw = Stopwatch()..start();

    var completedCount = 0;
    final totalCount = images.length;

    try {
      await for (final progress in _bridge.compressStream(requests: requests)) {
        completedCount++;
        final source = imageMap[progress.id];

        AppLog.debug(
          _tag,
          'compressBatchStream() received item id=${progress.id} '
          'success=${progress.success} completed=$completedCount/$totalCount '
          'elapsed=${batchSw.elapsedMilliseconds}ms',
        );

        if (source == null) {
          AppLog.warn(_tag, 'compressBatchStream() id=${progress.id} has no matching source image — skipping');
          continue;
        }

        if (progress.success && progress.response != null) {
          final resp = progress.response!;
          var finalOutputPath = resp.outputPath;
          final actualExt = '.${resp.format}';
          if (path.extension(finalOutputPath) != actualExt) {
            final newPath = path.join(
              path.dirname(finalOutputPath),
              '${path.basenameWithoutExtension(finalOutputPath)}$actualExt',
            );
            AppLog.info(_tag, 'compressBatchStream() renamed output from $finalOutputPath to $newPath due to size guard format change');
            final file = File(finalOutputPath);
            if (await file.exists()) {
              await file.rename(newPath);
            }
            finalOutputPath = newPath;
          }

          AppLog.info(
            _tag,
            'compressBatchStream() OK file=${source.fileName} '
            'original=${resp.originalBytes}B compressed=${resp.compressedBytes}B '
            'dims=${resp.width}x${resp.height}',
          );
          final result = CompressedImage(
            source: source,
            outputPath: finalOutputPath,
            outputFileName: path.basename(finalOutputPath),
            originalBytes: resp.originalBytes,
            compressedBytes: resp.compressedBytes,
          );
          yield CompressionTaskUpdate(
            total: totalCount,
            completed: completedCount,
            currentImageName: source.fileName,
            result: result,
            source: source,
          );
        } else {
          AppLog.warn(
            _tag,
            'compressBatchStream() native FAILED for file=${source.fileName} '
            'error=${progress.error} — falling back to raster engine',
          );
          // Fallback single image
          try {
            final fallbackResult = await fallbackDataSource.compressImage(
              image: source,
              preset: preset,
            );
            AppLog.info(_tag, 'compressBatchStream() fallback SUCCESS file=${source.fileName}');
            yield CompressionTaskUpdate(
              total: totalCount,
              completed: completedCount,
              currentImageName: source.fileName,
              result: fallbackResult,
              source: source,
            );
          } on AppFailure catch (failure) {
            AppLog.error(_tag, 'compressBatchStream() fallback FAILED file=${source.fileName} failure=${failure.message}');
            yield CompressionTaskUpdate(
              total: totalCount,
              completed: completedCount,
              currentImageName: source.fileName,
              failure: failure,
              source: source,
            );
          } catch (err, st) {
            AppLog.error(_tag, 'compressBatchStream() fallback unexpected error file=${source.fileName}', error: err, stackTrace: st);
            yield CompressionTaskUpdate(
              total: totalCount,
              completed: completedCount,
              currentImageName: source.fileName,
              source: source,
              failure: AppFailure('Compression failed for ${source.fileName}', details: err.toString()),
            );
          }
        }
      }
      AppLog.info(
        _tag,
        'compressBatchStream() STREAM COMPLETE total=$totalCount completed=$completedCount '
        'elapsed=${batchSw.elapsedMilliseconds}ms',
      );
    } catch (e, st) {
      AppLog.error(
        _tag,
        'compressBatchStream() STREAM BROKE after $completedCount/$totalCount — falling back entire remaining batch',
        error: e,
        stackTrace: st,
      );
      // Stream-level fallback: hand off everything to the raster engine
      yield* fallbackDataSource.compressBatchStream(images: images, preset: preset);
    }
  }

  frb.ResizeMode _mapResizeMode(ImageResizeMode mode) {
    return mode.when(
      none: () => const frb.ResizeMode.none(),
      maxLongEdge: (value) => frb.ResizeMode.maxLongEdge(value: value),
      exactSize: (w, h, ratio) => frb.ResizeMode.exactSize(width: w, height: h, keepAspectRatio: ratio),
      scalePercentage: (percentage) => frb.ResizeMode.scalePercentage(percentage: percentage),
    );
  }

  frb.OutputFormat _mapOutputFormat(SupportedImageFormat inputFormat, TargetFormat targetFormat) {
    switch (targetFormat) {
      case TargetFormat.jpeg:
        return frb.OutputFormat.jpeg;
      case TargetFormat.png:
        return frb.OutputFormat.png;
      case TargetFormat.webp:
        return frb.OutputFormat.webp;
      case TargetFormat.auto:
        switch (inputFormat) {
          case SupportedImageFormat.png:
            return frb.OutputFormat.png;
          case SupportedImageFormat.webp:
            return frb.OutputFormat.webp;
          default:
            return frb.OutputFormat.jpeg;
        }
    }
  }

  String _resolveExtension(SupportedImageFormat inputFormat, TargetFormat targetFormat) {
    switch (targetFormat) {
      case TargetFormat.jpeg:
        return '.jpg';
      case TargetFormat.png:
        return '.png';
      case TargetFormat.webp:
        return '.webp';
      case TargetFormat.auto:
        switch (inputFormat) {
          case SupportedImageFormat.png:
            return '.png';
          case SupportedImageFormat.webp:
            return '.webp';
          default:
            return '.jpg';
        }
    }
  }
}
