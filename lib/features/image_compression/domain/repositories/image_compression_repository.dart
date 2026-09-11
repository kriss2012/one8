import '../entities/compressed_image.dart';
import '../entities/compression_preset.dart';
import '../entities/compression_task_update.dart';
import '../entities/selected_image.dart';

abstract class ImageCompressionRepository {
  Future<List<SelectedImage>> pickImages();

  Future<String?> pickExportDirectory();

  Future<String> getDefaultExportDirectory();

  Stream<CompressionTaskUpdate> compressImages({
    required List<SelectedImage> images,
    required CompressionPreset preset,
  });

  Future<void> saveCompressedImages({
    required List<CompressedImage> images,
    required String destinationDirectory,
  });

  Future<void> shareCompressedImages(List<CompressedImage> images);
}
