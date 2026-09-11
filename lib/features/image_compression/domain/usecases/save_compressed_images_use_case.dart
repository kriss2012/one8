import '../entities/compressed_image.dart';
import '../repositories/image_compression_repository.dart';

class SaveCompressedImagesUseCase {
  const SaveCompressedImagesUseCase(this._repository);

  final ImageCompressionRepository _repository;

  Future<void> call({
    required List<CompressedImage> images,
    required String destinationDirectory,
  }) {
    return _repository.saveCompressedImages(
      images: images,
      destinationDirectory: destinationDirectory,
    );
  }
}
