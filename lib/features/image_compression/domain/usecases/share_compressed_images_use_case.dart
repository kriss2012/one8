import '../entities/compressed_image.dart';
import '../repositories/image_compression_repository.dart';

class ShareCompressedImagesUseCase {
  const ShareCompressedImagesUseCase(this._repository);

  final ImageCompressionRepository _repository;

  Future<void> call(List<CompressedImage> images) {
    return _repository.shareCompressedImages(images);
  }
}
