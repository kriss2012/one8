import '../entities/compression_history_item.dart';

abstract class ICompressionHistoryRepository {
  Future<void> saveCompressionHistory(CompressionHistoryItem item);
  Future<void> deleteCompressionHistory(int id);
  Future<void> clearHistory();
  
  /// Returns a stream of history items, sorted by timestamp descending
  Stream<List<CompressionHistoryItem>> watchHistory();
  
  Future<List<CompressionHistoryItem>> getHistory({int limit = 100, int offset = 0});
}
