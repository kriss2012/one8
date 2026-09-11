import '../../domain/entities/compression_history_item.dart';
import '../../domain/repositories/i_compression_history_repository.dart';
import '../datasources/local_database_data_source.dart';
import '../models/compression_history_mapper.dart';

class CompressionHistoryRepositoryImpl implements ICompressionHistoryRepository {
  final LocalDatabaseDataSource _dataSource;

  CompressionHistoryRepositoryImpl(this._dataSource);

  @override
  Future<void> saveCompressionHistory(CompressionHistoryItem item) async {
    await _dataSource.save(item.toModel());
  }

  @override
  Future<void> deleteCompressionHistory(int id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<void> clearHistory() async {
    await _dataSource.clearAll();
  }

  @override
  Stream<List<CompressionHistoryItem>> watchHistory() {
    return _dataSource.watchAll().map(
      (models) => models.map((e) => e.toDomain()).toList(),
    );
  }

  @override
  Future<List<CompressionHistoryItem>> getHistory({int limit = 100, int offset = 0}) async {
    final models = await _dataSource.getAll(limit: limit, offset: offset);
    return models.map((e) => e.toDomain()).toList();
  }
}
