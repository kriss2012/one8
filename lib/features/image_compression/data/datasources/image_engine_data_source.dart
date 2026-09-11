import '../../domain/entities/compressed_image.dart';
import '../../domain/entities/compression_preset.dart';
import '../../domain/entities/compression_task_update.dart';
import '../../domain/entities/selected_image.dart';

abstract class ImageEngineDataSource {
  Future<CompressedImage> compressImage({
    required SelectedImage image,
    required CompressionPreset preset,
  });

  Stream<CompressionTaskUpdate> compressBatchStream({
    required List<SelectedImage> images,
    required CompressionPreset preset,
  });
}
