import '../entities/compression_preset.dart';
import '../entities/compression_task_update.dart';
import '../entities/selected_image.dart';
import '../repositories/image_compression_repository.dart';

class CompressImagesUseCase {
  const CompressImagesUseCase(this._repository);

  final ImageCompressionRepository _repository;

  Stream<CompressionTaskUpdate> call({
    required List<SelectedImage> images,
    required CompressionPreset preset,
  }) {
    return _repository.compressImages(images: images, preset: preset);
  }
}
