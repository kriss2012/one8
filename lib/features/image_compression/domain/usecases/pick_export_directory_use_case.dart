import '../repositories/image_compression_repository.dart';

class PickExportDirectoryUseCase {
  const PickExportDirectoryUseCase(this._repository);

  final ImageCompressionRepository _repository;

  Future<String?> call() => _repository.pickExportDirectory();
}
