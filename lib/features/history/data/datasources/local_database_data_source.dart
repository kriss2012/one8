
import '../../../../core/database/objectbox_service.dart';
import '../../../../objectbox.g.dart';
import '../models/compression_history_model.dart';


class LocalDatabaseDataSource {
  final ObjectBoxService _objectBoxService;
  late final Box<CompressionHistoryModel> _box;

  LocalDatabaseDataSource(this._objectBoxService) {
    _box = _objectBoxService.store.box<CompressionHistoryModel>();
  }

  Future<void> save(CompressionHistoryModel model) async {
    _box.put(model);
  }

  Future<void> delete(int id) async {
    _box.remove(id);
  }

  Future<void> clearAll() async {
    _box.removeAll();
  }

  Stream<List<CompressionHistoryModel>> watchAll() {
    final builder = _box.query().order(CompressionHistoryModel_.timestamp, flags: Order.descending);
    return builder.watch(triggerImmediately: true).map((q) => q.find());
  }



  Future<List<CompressionHistoryModel>> getAll({int limit = 100, int offset = 0}) async {
    final query = _box.query().order(CompressionHistoryModel_.timestamp, flags: Order.descending).build();
    query.limit = limit;
    query.offset = offset;
    final results = query.find();
    query.close();
    return results;
  }
}
