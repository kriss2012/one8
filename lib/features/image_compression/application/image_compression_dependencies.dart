import '../../history/domain/repositories/i_compression_history_repository.dart';
import '../data/datasources/file_picker_data_source.dart';


import '../data/datasources/image_engine_data_source_factory.dart';
import '../data/datasources/share_data_source.dart';
import '../data/repositories/image_compression_repository_impl.dart';
import '../domain/usecases/compress_images_use_case.dart';
import '../domain/usecases/get_default_export_directory_use_case.dart';
import '../domain/usecases/pick_export_directory_use_case.dart';
import '../domain/usecases/pick_images_use_case.dart';
import '../domain/usecases/save_compressed_images_use_case.dart';
import '../domain/usecases/share_compressed_images_use_case.dart';

class ImageCompressionDependencies {
  const ImageCompressionDependencies({
    required this.pickImages,
    required this.pickExportDirectory,
    required this.getDefaultExportDirectory,
    required this.compressImages,
    required this.saveCompressedImages,
    required this.shareCompressedImages,
    required this.historyRepository,
  });

  final PickImagesUseCase pickImages;
  final PickExportDirectoryUseCase pickExportDirectory;
  final GetDefaultExportDirectoryUseCase getDefaultExportDirectory;
  final CompressImagesUseCase compressImages;
  final SaveCompressedImagesUseCase saveCompressedImages;
  final ShareCompressedImagesUseCase shareCompressedImages;
  final ICompressionHistoryRepository historyRepository;

  factory ImageCompressionDependencies.create({
    required ICompressionHistoryRepository historyRepository,
  }) {
    final repository = ImageCompressionRepositoryImpl(
      filePickerDataSource: FilePickerDataSource(),
      imageEngineDataSource: createImageEngineDataSource(),
      shareDataSource: ShareDataSource(),
    );

    return ImageCompressionDependencies(
      pickImages: PickImagesUseCase(repository),
      pickExportDirectory: PickExportDirectoryUseCase(repository),
      getDefaultExportDirectory: GetDefaultExportDirectoryUseCase(repository),
      compressImages: CompressImagesUseCase(repository),
      saveCompressedImages: SaveCompressedImagesUseCase(repository),
      shareCompressedImages: ShareCompressedImagesUseCase(repository),
      historyRepository: historyRepository,
    );
  }
}

