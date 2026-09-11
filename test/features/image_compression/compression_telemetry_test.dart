import 'package:flutter_test/flutter_test.dart';
import 'package:one8/core/utils/byte_formatter.dart';
import 'package:one8/features/image_compression/presentation/controllers/compression_telemetry.dart';

void main() {
  group('ByteConverter Tests', () {
    test('converts bytes to MB and KB correctly', () {
      expect(ByteConverter.toMb(1024 * 1024 * 5), 5.0);
      expect(ByteConverter.toKb(1024 * 10), 10.0);
      expect(ByteConverter.mbToBytes(2.5), (2.5 * 1024 * 1024).round());
      expect(ByteConverter.kbToBytes(500), 500 * 1024);
    });

    test('formatBytes formats human readable strings correctly', () {
      expect(formatBytes(500), '500 B');
      expect(formatBytes(2048), '2.0 KB');
      expect(formatBytes(5 * 1024 * 1024), '5.0 MB');
    });
  });

  group('CompressionTelemetry Tests', () {
    test('calculates progress accurately', () {
      const telemetry = CompressionTelemetry(completedCount: 5, totalCount: 10);
      expect(telemetry.progress, 0.5);
    });

    test('calculates estimated seconds remaining accurately', () {
      const telemetry = CompressionTelemetry(
        completedCount: 5,
        totalCount: 10,
        elapsedMilliseconds: 5000,
      );
      expect(telemetry.estimatedSecondsRemaining, 5.0);
    });

    test('copyWith produces updated immutable instance', () {
      const initial = CompressionTelemetry();
      final updated = initial.copyWith(completedCount: 3, totalCount: 5);
      expect(updated.completedCount, 3);
      expect(updated.totalCount, 5);
      expect(updated.progress, 0.6);
    });
  });
}
