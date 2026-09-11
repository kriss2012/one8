import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/extensions/iterable_extensions.dart';
import '../../../../core/utils/app_log.dart';
import '../../../../core/utils/byte_formatter.dart';
import '../../domain/entities/compressed_image.dart';
import '../../domain/entities/compression_preset.dart';
import '../../domain/entities/selected_image.dart';
import '../../domain/usecases/compress_images_use_case.dart';
import '../../domain/usecases/get_default_export_directory_use_case.dart';
import '../../domain/usecases/pick_export_directory_use_case.dart';
import '../../domain/usecases/pick_images_use_case.dart';
import '../../domain/usecases/save_compressed_images_use_case.dart';
import '../../domain/usecases/share_compressed_images_use_case.dart';
import '../../../history/domain/entities/compression_history_item.dart';
import '../../../history/domain/repositories/i_compression_history_repository.dart';
import 'compression_telemetry.dart';


class ImageCompressionController extends ChangeNotifier {
  ImageCompressionController({
    required this.pickImagesUseCase,
    required this.pickExportDirectoryUseCase,
    required this.getDefaultExportDirectoryUseCase,
    required this.compressImagesUseCase,
    required this.saveCompressedImagesUseCase,
    required this.shareCompressedImagesUseCase,
    required this.historyRepository,
  });

  final PickImagesUseCase pickImagesUseCase;
  final PickExportDirectoryUseCase pickExportDirectoryUseCase;
  final GetDefaultExportDirectoryUseCase getDefaultExportDirectoryUseCase;
  final CompressImagesUseCase compressImagesUseCase;
  final SaveCompressedImagesUseCase saveCompressedImagesUseCase;
  final ShareCompressedImagesUseCase shareCompressedImagesUseCase;
  final ICompressionHistoryRepository historyRepository;


  // ─── State ─────────────────────────────────────────────────────────────────

  List<SelectedImage> _selectedImages = const [];

  // Use a growable list for O(1) append instead of O(n) spread on every update.
  final List<CompressedImage> _compressedImages = [];

  CompressionPreset _preset = CompressionPreset.balanced;
  bool _isCompressing = false;
  String? _statusMessage;
  String? _errorMessage;

  // ─── Progress Telemetry ────────────────────────────────────────────────────

  CompressionTelemetry _telemetry = const CompressionTelemetry();
  DateTime? _compressionStartTime;
  StreamSubscription<dynamic>? _compressionSubscription;

  // ─── Getters ────────────────────────────────────────────────────────────────

  List<SelectedImage> get selectedImages => _selectedImages;
  List<CompressedImage> get compressedImages => List.unmodifiable(_compressedImages);
  CompressionPreset get preset => _preset;
  bool get isCompressing => _isCompressing;
  CompressionTelemetry get telemetry => _telemetry;
  int get completedCount => _telemetry.completedCount;
  int get totalCount => _telemetry.totalCount;
  String? get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  int get elapsedMilliseconds => _telemetry.elapsedMilliseconds;
  double get processingSpeedMBps => _telemetry.processingSpeedMBps;

  /// Progress as 0.0–1.0. Returns 0 when no compression is running.
  double get progress => _telemetry.progress;

  /// Estimated seconds remaining based on current throughput.
  /// Returns null when there is no meaningful data.
  double? get estimatedSecondsRemaining =>
      _isCompressing ? _telemetry.estimatedSecondsRemaining : null;

  int get totalOriginalBytes =>
      _selectedImages.fold(0, (sum, image) => sum + image.originalBytes);

  int get totalCompressedBytes =>
      _compressedImages.fold(0, (sum, image) => sum + image.compressedBytes);

  double get savedPercentage {
    final processedBytes = _telemetry.processedOriginalBytes;
    if (processedBytes == 0 || _compressedImages.isEmpty) return 0;
    final saved = processedBytes - totalCompressedBytes;
    return ((saved / processedBytes) * 100).clamp(0.0, 100.0);
  }

  // ─── Preset / Settings ─────────────────────────────────────────────────────

  int get detectedOriginalBytes {
    if (_selectedImages.isEmpty) return 0;
    return totalOriginalBytes;
  }

  String get detectedOriginalSizeFormatted {
    if (_selectedImages.isEmpty) return '0 B';
    return formatBytes(detectedOriginalBytes);
  }

  void selectPreset(CompressionPreset preset) {
    _preset = preset;
    notifyListeners();
  }

  void updateQuality(double quality) {
    _preset = _preset.copyWith(
      id: 'custom',
      label: 'Custom',
      description: 'Fine-tuned custom parameters.',
      quality: quality.round(),
      pngLevel: _mapPngLevel(quality.round()),
      targetSizeBytes: null,
    );
    notifyListeners();
  }

  void updateTargetSizeBytes(int? bytes) {
    _preset = _preset.copyWith(
      id: 'custom_target_size',
      label: 'Target Size',
      description: 'Compressing to target size.',
      targetSizeBytes: bytes,
    );
    notifyListeners();
  }

  void updateResizeMode(ImageResizeMode mode) {
    _preset = _preset.copyWith(
      id: 'custom',
      label: 'Custom',
      description: 'Fine-tuned custom parameters.',
      resizeMode: mode,
    );
    notifyListeners();
  }

  void updateTargetFormat(TargetFormat format) {
    _preset = _preset.copyWith(
      id: 'custom',
      label: 'Custom',
      description: 'Fine-tuned custom parameters.',
      targetFormat: format,
    );
    notifyListeners();
  }

  // ─── Image Management ──────────────────────────────────────────────────────

  void removeSelectedImage(SelectedImage image) {
    _selectedImages = _selectedImages.where((i) => i.path != image.path).toList();
    _compressedImages.removeWhere((i) => i.source.path == image.path);
    _statusMessage = _selectedImages.isEmpty
        ? 'No images selected.'
        : '${_selectedImages.length} image${_selectedImages.length == 1 ? '' : 's'} ready.';
    notifyListeners();
  }

  void clearAll() {
    cancelCompression();
    _selectedImages = const [];
    _compressedImages.clear();
    _resetTelemetry();
    _statusMessage = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Pick Images ───────────────────────────────────────────────────────────

  Future<void> pickImages() async {
    AppLog.info('Controller', 'pickImages() called');
    _setError(null);
    try {
      final images = await pickImagesUseCase();
      _selectedImages = images;
      _compressedImages.clear();
      _resetTelemetry();
      _statusMessage = images.isEmpty
          ? 'No images selected yet.'
          : '${images.length} image${images.length == 1 ? '' : 's'} ready to compress.';
      AppLog.info('Controller', 'pickImages() done — selected=${images.length} images');
      notifyListeners();
    } on AppFailure catch (failure) {
      AppLog.error('Controller', 'pickImages() AppFailure: ${failure.message}');
      _setError(failure.message);
    } catch (error) {
      AppLog.error('Controller', 'pickImages() unexpected error', error: error);
      _setError('Unable to pick images: $error');
    }
  }

  Future<void> addMoreImages() async {
    AppLog.info('Controller', 'addMoreImages() called');
    _setError(null);
    try {
      final newImages = await pickImagesUseCase();
      if (newImages.isEmpty) return;
      final existingPaths = _selectedImages.map((i) => i.path).toSet();
      final filteredNew = newImages.where((i) => !existingPaths.contains(i.path)).toList();
      if (filteredNew.isEmpty) return;
      _selectedImages = [..._selectedImages, ...filteredNew];
      _statusMessage = '${_selectedImages.length} image${_selectedImages.length == 1 ? '' : 's'} in batch ready.';
      AppLog.info('Controller', 'addMoreImages() done — total now ${_selectedImages.length}');
      notifyListeners();
    } on AppFailure catch (failure) {
      AppLog.error('Controller', 'addMoreImages() AppFailure: ${failure.message}');
      _setError(failure.message);
    } catch (error) {
      AppLog.error('Controller', 'addMoreImages() unexpected error', error: error);
      _setError('Unable to add more images: $error');
    }
  }

  // ─── Compress ─────────────────────────────────────────────────────────────

  Future<void> compress() async {
    if (_selectedImages.isEmpty || _isCompressing) {
      AppLog.warn('Controller', 'compress() called but images=${_selectedImages.length} isCompressing=$_isCompressing — skipped');
      return;
    }

    AppLog.info(
      'Controller',
      'compress() START images=${_selectedImages.length} '
      'preset=${_preset.id} quality=${_preset.quality} '
      'pngLevel=${_preset.pngLevel} targetFormat=${_preset.targetFormat} '
      'resizeMode=${_preset.resizeMode}',
    );

    _isCompressing = true;
    _compressedImages.clear();
    _resetTelemetry();
    _telemetry = _telemetry.copyWith(totalCount: _selectedImages.length);
    _setError(null, notify: false);
    _statusMessage = 'Firing up ${_selectedImages.length} image${_selectedImages.length == 1 ? '' : 's'} on Rayon engine...';
    _compressionStartTime = DateTime.now();
    notifyListeners();

    final stream = compressImagesUseCase(images: _selectedImages, preset: _preset);
    AppLog.info('Controller', 'compress() stream obtained — subscribing');

    DateTime? lastNotify;
    int notifyCount = 0;
    int suppressedCount = 0;

    _compressionSubscription = stream.listen(
      (update) {
        var newCompleted = update.completed;
        var newProcessedBytes = _telemetry.processedOriginalBytes;

        if (update.result != null) {
          _compressedImages.add(update.result!);
          newProcessedBytes += update.result!.originalBytes;
          
          final item = CompressionHistoryItem(
            id: 0,
            originalPath: update.result!.source.path,
            outputPath: update.result!.outputPath,
            outputFileName: update.result!.outputFileName,
            originalBytes: update.result!.originalBytes,
            compressedBytes: update.result!.compressedBytes,
            timestamp: DateTime.now(),
            format: update.result!.source.format.name,
          );
          historyRepository.saveCompressionHistory(item);
        }

        if (update.failure != null && _errorMessage == null) {
          _errorMessage = update.failure!.message;
          AppLog.warn('Controller', 'stream event failure for ${update.currentImageName}: ${update.failure!.message}');
        }

        final now = DateTime.now();
        var elapsedMs = _telemetry.elapsedMilliseconds;
        var speedMBps = _telemetry.processingSpeedMBps;

        if (_compressionStartTime != null) {
          elapsedMs = now.difference(_compressionStartTime!).inMilliseconds;
          final elapsedSeconds = elapsedMs / 1000.0;
          if (elapsedSeconds > 0.05 && newProcessedBytes > 0) {
            speedMBps = ByteConverter.toMb(newProcessedBytes) / elapsedSeconds;
          }
        }

        _telemetry = _telemetry.copyWith(
          completedCount: newCompleted,
          processedOriginalBytes: newProcessedBytes,
          elapsedMilliseconds: elapsedMs,
          processingSpeedMBps: speedMBps,
        );

        _statusMessage = update.failure == null
            ? '${update.currentImageName}'
            : 'Skipped ${update.currentImageName}: ${update.failure!.message}';

        // Throttle: only push to UI at ~60fps (16ms gate)
        if (lastNotify == null || now.difference(lastNotify!).inMilliseconds >= 16) {
          lastNotify = now;
          notifyCount++;
          notifyListeners();
          AppLog.debug(
            'Controller',
            'stream event NOTIFY #$notifyCount '
            'completed=${_telemetry.completedCount}/${_telemetry.totalCount} '
            'progress=${(progress * 100).toStringAsFixed(1)}% '
            'speed=${_telemetry.processingSpeedMBps.toStringAsFixed(1)}MB/s '
            'elapsed=${_telemetry.elapsedMilliseconds}ms '
            'suppressed_since_last=$suppressedCount',
          );
          suppressedCount = 0;
        } else {
          suppressedCount++;
        }
      },
      onError: (Object error, StackTrace st) {
        AppLog.error('Controller', 'compress() stream onError', error: error, stackTrace: st);
        _setError('Engine error: $error');
        _isCompressing = false;
        notifyListeners();
      },
      onDone: () {
        _isCompressing = false;
        final now = DateTime.now();
        var ms = _telemetry.elapsedMilliseconds;
        if (_compressionStartTime != null) {
          ms = now.difference(_compressionStartTime!).inMilliseconds;
          _telemetry = _telemetry.copyWith(elapsedMilliseconds: ms);
        }
        final count = _compressedImages.length;
        final mbps = _telemetry.processingSpeedMBps.toStringAsFixed(1);
        _statusMessage = count == 0
            ? 'No files were compressed.'
            : '✅ $count file${count == 1 ? '' : 's'} done in ${ms}ms · $mbps MB/s';
        notifyListeners();
      },
    );
  }

  Future<void> compressSingleImage(SelectedImage image, CompressionPreset customPreset) async {
    if (_isCompressing) {
      AppLog.warn('Controller', 'compressSingleImage() called but isCompressing=true — skipped');
      return;
    }

    AppLog.info('Controller', 'compressSingleImage() START for ${image.fileName}');
    _isCompressing = true;
    _setError(null, notify: false);
    _statusMessage = 'Compressing ${image.fileName}...';
    notifyListeners();

    // Remove existing result if any
    _compressedImages.removeWhere((i) => i.source.path == image.path);

    final stream = compressImagesUseCase(images: [image], preset: customPreset);
    
    _compressionSubscription = stream.listen(
      (update) {
        if (update.result != null) {
          _compressedImages.add(update.result!);
          final item = CompressionHistoryItem(
            id: 0,
            originalPath: update.result!.source.path,
            outputPath: update.result!.outputPath,
            outputFileName: update.result!.outputFileName,
            originalBytes: update.result!.originalBytes,
            compressedBytes: update.result!.compressedBytes,
            timestamp: DateTime.now(),
            format: update.result!.source.format.name,
          );
          historyRepository.saveCompressionHistory(item);
        }
        if (update.failure != null) {
          _errorMessage = update.failure!.message;
        }
        notifyListeners();
      },
      onError: (Object error, StackTrace st) {
        AppLog.error('Controller', 'compressSingleImage() stream onError', error: error, stackTrace: st);
        _setError('Engine error: $error');
        _isCompressing = false;
        notifyListeners();
      },
      onDone: () {
        _isCompressing = false;
        _statusMessage = 'Finished compressing ${image.fileName}';
        notifyListeners();
      },
    );
  }

  // ─── Cancel ────────────────────────────────────────────────────────────────

  void cancelCompression() {
    AppLog.info('Controller', 'cancelCompression() called isCompressing=$_isCompressing');
    _compressionSubscription?.cancel();
    _compressionSubscription = null;
    if (_isCompressing) {
      _isCompressing = false;
      _statusMessage = 'Compression cancelled.';
      notifyListeners();
    }
  }

  // ─── Save / Share ──────────────────────────────────────────────────────────

  Future<String?> saveCompressedImages({String? customDirectory}) async {
    if (_compressedImages.isEmpty) return null;
    final directory = customDirectory ?? await getDefaultExportDirectoryUseCase();
    try {
      await saveCompressedImagesUseCase(images: _compressedImages, destinationDirectory: directory);
      _statusMessage = 'Saved ${_compressedImages.length} compressed image(s) to ONE8 folder.';
      notifyListeners();
      return directory;
    } on AppFailure catch (failure) {
      _setError(failure.message);
      return null;
    } catch (error) {
      _setError('Unable to save files: $error');
      return null;
    }
  }

  Future<void> shareCompressedImages() async {
    if (_compressedImages.isEmpty) return;
    try {
      await shareCompressedImagesUseCase(_compressedImages);
      _statusMessage = 'Share sheet opened.';
      notifyListeners();
    } on AppFailure catch (failure) {
      _setError(failure.message);
    } catch (error) {
      _setError('Unable to share files: $error');
    }
  }

  // ─── Lookups ────────────────────────────────────────────────────────────────

  CompressedImage? resultFor(String path) {
    return _compressedImages.firstWhereOrNull(
      (result) => result.source.path == path,
    );
  }

  // ─── Private Helpers ───────────────────────────────────────────────────────

  void _resetTelemetry() {
    _telemetry = const CompressionTelemetry();
    _compressionStartTime = null;
  }

  int _mapPngLevel(int quality) {
    if (quality >= 85) return 4;
    if (quality >= 70) return 6;
    return 8;
  }

  void _setError(String? value, {bool notify = true}) {
    _errorMessage = value;
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _compressionSubscription?.cancel();
    super.dispose();
  }
}
