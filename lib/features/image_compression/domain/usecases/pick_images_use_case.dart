import '../entities/selected_image.dart';
import '../repositories/image_compression_repository.dart';

class PickImagesUseCase {
  const PickImagesUseCase(this._repository);

  final ImageCompressionRepository _repository;

  Future<List<SelectedImage>> call() => _repository.pickImages();
}
