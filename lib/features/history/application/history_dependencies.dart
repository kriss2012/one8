import '../../../core/database/objectbox_service.dart';
import '../data/datasources/local_database_data_source.dart';
import '../data/repositories/compression_history_repository_impl.dart';
import '../domain/repositories/i_compression_history_repository.dart';

class HistoryDependencies {
  const HistoryDependencies({
    required this.repository,
  });

  final ICompressionHistoryRepository repository;

  static Future<HistoryDependencies> create() async {
    final objectBoxService = await ObjectBoxService.create();
    final dataSource = LocalDatabaseDataSource(objectBoxService);
    final repository = CompressionHistoryRepositoryImpl(dataSource);

    return HistoryDependencies(
      repository: repository,
    );
  }
}
