import '../repositories/image_compression_repository.dart';

class GetDefaultExportDirectoryUseCase {
  const GetDefaultExportDirectoryUseCase(this._repository);

  final ImageCompressionRepository _repository;

  Future<String> call() => _repository.getDefaultExportDirectory();
}
