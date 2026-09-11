import 'package:freezed_annotation/freezed_annotation.dart';

part 'compression_history_item.freezed.dart';

@freezed
abstract class CompressionHistoryItem with _$CompressionHistoryItem {
  const factory CompressionHistoryItem({
    required int id,
    required String originalPath,
    required String outputPath,
    required String outputFileName,
    required int originalBytes,
    required int compressedBytes,
    required DateTime timestamp,
    required String format,
  }) = _CompressionHistoryItem;

  const CompressionHistoryItem._();

  double get savingsRatio {
    if (originalBytes == 0) {
      return 0;
    }
    return 1 - (compressedBytes / originalBytes);
  }

  double get savedPercentage => (savingsRatio * 100).clamp(0, 100);
}
