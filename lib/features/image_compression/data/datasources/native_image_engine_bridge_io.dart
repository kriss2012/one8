import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:path/path.dart' as path;

import '../../../../core/utils/app_log.dart';
import '../../../../src/rust/api/image_engine.dart' as frb;
import '../../../../src/rust/frb_generated.dart';

class NativeImageEngineBridge {
  const NativeImageEngineBridge._();

  static const instance = NativeImageEngineBridge._();
  static bool _initialized = false;

  bool get isSupportedPlatform =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isLinux ||
      Platform.isMacOS ||
      Platform.isWindows;

  bool get isAvailable => isSupportedPlatform;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      AppLog.debug('Bridge', 'RustLib already initialized, skipping');
      return;
    }

    AppLog.info('Bridge', 'Initializing RustLib — platform=${Platform.operatingSystem}');
    final sw = Stopwatch()..start();

    try {
      if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
        AppLog.info('Bridge', 'Using bundled native library (no explicit path needed)');
        await RustLib.init();
      } else {
        final libraryPath = _findLibraryPath();
        AppLog.info('Bridge', 'Desktop platform — resolving library path: ${libraryPath ?? "NOT FOUND"}');
        if (libraryPath != null) {
          await RustLib.init(externalLibrary: ExternalLibrary.open(libraryPath));
        } else {
          AppLog.warn('Bridge', 'No native library found on disk — attempting default RustLib.init()');
          await RustLib.init();
        }
      }
      _initialized = true;
      AppLog.info('Bridge', 'RustLib initialized successfully in ${sw.elapsedMilliseconds}ms');
    } catch (e, st) {
      AppLog.error('Bridge', 'RustLib initialization FAILED', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<NativeCompressionResponse> compress({
    required String id,
    required String inputPath,
    required String outputPath,
    required int quality,
    required int pngLevel,
    required frb.ResizeMode resizeMode,
    required frb.OutputFormat outputFormat,
    BigInt? targetSizeBytes,
  }) async {
    AppLog.info('Bridge', 'compress() id=$id inputPath=$inputPath quality=$quality targetSizeBytes=$targetSizeBytes');
    await ensureInitialized();

    final sw = Stopwatch()..start();
    final request = frb.CompressionRequest(
      id: id,
      inputPath: inputPath,
      outputPath: outputPath,
      quality: quality,
      pngLevel: pngLevel,
      resizeMode: resizeMode,
      outputFormat: outputFormat,
      targetSizeBytes: targetSizeBytes,
    );

    try {
      final response = await frb.compressImage(request: request);
      AppLog.info(
        'Bridge',
        'compress() DONE id=$id elapsed=${sw.elapsedMilliseconds}ms '
        'original=${response.originalBytes}B compressed=${response.compressedBytes}B',
      );
      return NativeCompressionResponse(
        id: response.id,
        outputPath: response.outputPath,
        originalBytes: response.originalBytes,
        compressedBytes: response.compressedBytes,
        width: response.width,
        height: response.height,
        format: response.format,
      );
    } catch (e, st) {
      AppLog.error('Bridge', 'compress() FAILED id=$id elapsed=${sw.elapsedMilliseconds}ms', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<frb.CompressionTaskProgress> compressStream({
    required List<frb.CompressionRequest> requests,
  }) async* {
    AppLog.info('Bridge', 'compressStream() START total=${requests.length} requests');
    await ensureInitialized();

    final sw = Stopwatch()..start();
    int received = 0;
    try {
      await for (final item in frb.compressImagesStream(requests: requests)) {
        received++;
        if (item.success) {
          AppLog.info(
            'Bridge',
            'compressStream() item_received id=${item.id} '
            'received=$received/${requests.length} '
            'elapsed_total=${sw.elapsedMilliseconds}ms',
          );
        } else {
          AppLog.warn(
            'Bridge',
            'compressStream() item_failed id=${item.id} '
            'received=$received/${requests.length} '
            'error=${item.error}',
          );
        }
        yield item;
      }
      AppLog.info(
        'Bridge',
        'compressStream() DONE total=${requests.length} received=$received '
        'elapsed=${sw.elapsedMilliseconds}ms',
      );
    } catch (e, st) {
      AppLog.error(
        'Bridge',
        'compressStream() STREAM_ERROR after $received items elapsed=${sw.elapsedMilliseconds}ms',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

class NativeCompressionResponse {
  const NativeCompressionResponse({
    required this.id,
    required this.outputPath,
    required this.originalBytes,
    required this.compressedBytes,
    required this.width,
    required this.height,
    required this.format,
  });

  final String id;
  final String outputPath;
  final int originalBytes;
  final int compressedBytes;
  final int width;
  final int height;
  final String format;
}

String? _findLibraryPath() {
  final fileName = _libraryFileName();
  if (fileName == null) {
    return null;
  }

  final environmentOverride =
      Platform.environment['ONE8_IMAGE_ENGINE_LIB'];
  if (environmentOverride != null && File(environmentOverride).existsSync()) {
    AppLog.info('Bridge', 'Using env override library path: $environmentOverride');
    return environmentOverride;
  }

  final executableDirectory = File(Platform.resolvedExecutable).parent.path;
  final candidates = <String>{
    path.join(Directory.current.path, fileName),
    path.join(executableDirectory, fileName),
    path.join(executableDirectory, 'lib', fileName),
    path.join(Directory.current.path, 'rust', 'image_engine', 'target', 'debug', fileName),
    path.join(Directory.current.path, 'rust', 'image_engine', 'target', 'release', fileName),
  };

  for (final candidate in candidates) {
    final exists = File(candidate).existsSync();
    AppLog.debug('Bridge', 'Library candidate: $candidate — exists=$exists');
    if (exists) return candidate;
  }

  return null;
}

String? _libraryFileName() {
  if (Platform.isAndroid) return 'libimage_engine.so';
  if (Platform.isLinux) return 'libimage_engine.so';
  if (Platform.isMacOS) return null;
  if (Platform.isIOS) return null;
  if (Platform.isWindows) return 'image_engine.dll';
  return null;
}
