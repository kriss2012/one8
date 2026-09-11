import 'package:flutter/foundation.dart';

/// Immutable value object representing progress & performance metrics of an ongoing image compression task.
@immutable
class CompressionTelemetry {
  const CompressionTelemetry({
    this.completedCount = 0,
    this.totalCount = 0,
    this.elapsedMilliseconds = 0,
    this.processedOriginalBytes = 0,
    this.processingSpeedMBps = 0.0,
  });

  final int completedCount;
  final int totalCount;
  final int elapsedMilliseconds;
  final int processedOriginalBytes;
  final double processingSpeedMBps;

  /// Progress as a double between 0.0 and 1.0. Returns 0.0 when no items exist.
  double get progress =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount).clamp(0.0, 1.0);

  /// Estimated seconds remaining based on current throughput rate.
  /// Returns null when metrics are insufficient.
  double? get estimatedSecondsRemaining {
    if (completedCount == 0 || totalCount == 0 || elapsedMilliseconds <= 0) {
      return null;
    }
    final elapsedSec = elapsedMilliseconds / 1000.0;
    final rate = completedCount / elapsedSec;
    final remaining = totalCount - completedCount;
    if (rate <= 0) return null;
    return remaining / rate;
  }

  CompressionTelemetry copyWith({
    int? completedCount,
    int? totalCount,
    int? elapsedMilliseconds,
    int? processedOriginalBytes,
    double? processingSpeedMBps,
  }) {
    return CompressionTelemetry(
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      elapsedMilliseconds: elapsedMilliseconds ?? this.elapsedMilliseconds,
      processedOriginalBytes:
          processedOriginalBytes ?? this.processedOriginalBytes,
      processingSpeedMBps: processingSpeedMBps ?? this.processingSpeedMBps,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompressionTelemetry &&
          runtimeType == other.runtimeType &&
          completedCount == other.completedCount &&
          totalCount == other.totalCount &&
          elapsedMilliseconds == other.elapsedMilliseconds &&
          processedOriginalBytes == other.processedOriginalBytes &&
          processingSpeedMBps == other.processingSpeedMBps;

  @override
  int get hashCode =>
      Object.hash(completedCount, totalCount, elapsedMilliseconds, processedOriginalBytes, processingSpeedMBps);
}
