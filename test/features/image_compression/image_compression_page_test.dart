import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:one8/app/app.dart';
import 'package:one8/features/history/domain/entities/compression_history_item.dart';
import 'package:one8/features/history/domain/repositories/i_compression_history_repository.dart';
import 'package:one8/features/image_compression/application/image_compression_dependencies.dart';
import 'package:one8/features/image_compression/data/datasources/file_picker_data_source.dart';
import 'package:one8/features/image_compression/data/datasources/raster_image_engine_data_source.dart';
import 'package:one8/features/image_compression/data/datasources/share_data_source.dart';
import 'package:one8/features/image_compression/data/repositories/image_compression_repository_impl.dart';
import 'package:one8/features/image_compression/domain/usecases/compress_images_use_case.dart';
import 'package:one8/features/image_compression/domain/usecases/get_default_export_directory_use_case.dart';
import 'package:one8/features/image_compression/domain/usecases/pick_export_directory_use_case.dart';
import 'package:one8/features/image_compression/domain/usecases/pick_images_use_case.dart';
import 'package:one8/features/image_compression/domain/usecases/save_compressed_images_use_case.dart';
import 'package:one8/features/image_compression/domain/usecases/share_compressed_images_use_case.dart';

class MockHistoryRepository implements ICompressionHistoryRepository {
  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> deleteCompressionHistory(int id) async {}

  @override
  Future<List<CompressionHistoryItem>> getHistory({int limit = 100, int offset = 0}) async => [];

  @override
  Future<void> saveCompressionHistory(CompressionHistoryItem item) async {}

  @override
  Stream<List<CompressionHistoryItem>> watchHistory() => Stream.value([]);
}

void main() {
  testWidgets('renders ONE8 home dashboard and floating nav bar', (tester) async {
    final repository = ImageCompressionRepositoryImpl(
      filePickerDataSource: FilePickerDataSource(),
      imageEngineDataSource: RasterImageEngineDataSource(),
      shareDataSource: ShareDataSource(),
    );

    await tester.pumpWidget(
      One8App(
        dependencies: ImageCompressionDependencies(
          pickImages: PickImagesUseCase(repository),
          pickExportDirectory: PickExportDirectoryUseCase(repository),
          getDefaultExportDirectory: GetDefaultExportDirectoryUseCase(repository),
          compressImages: CompressImagesUseCase(repository),
          saveCompressedImages: SaveCompressedImagesUseCase(repository),
          shareCompressedImages: ShareCompressedImagesUseCase(repository),
          historyRepository: MockHistoryRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ONE8'), findsOneWidget);
    expect(find.text('Compress'), findsOneWidget);
    expect(find.text('Resize'), findsOneWidget);
    expect(find.text('Recents'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}

