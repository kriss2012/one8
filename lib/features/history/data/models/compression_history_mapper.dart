import '../../domain/entities/compression_history_item.dart';
import 'compression_history_model.dart';

extension CompressionHistoryModelX on CompressionHistoryModel {
  CompressionHistoryItem toDomain() {
    return CompressionHistoryItem(
      id: id,
      originalPath: originalPath,
      outputPath: outputPath,
      outputFileName: outputFileName,
      originalBytes: originalBytes,
      compressedBytes: compressedBytes,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      format: format,
    );
  }
}

extension CompressionHistoryItemX on CompressionHistoryItem {
  CompressionHistoryModel toModel() {
    return CompressionHistoryModel(
      id: id,
      originalPath: originalPath,
      outputPath: outputPath,
      outputFileName: outputFileName,
      originalBytes: originalBytes,
      compressedBytes: compressedBytes,
      timestamp: timestamp.millisecondsSinceEpoch,
      format: format,
    );
  }
}
