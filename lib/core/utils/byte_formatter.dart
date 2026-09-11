abstract final class ByteConverter {
  static const int bytesPerKb = 1024;
  static const int bytesPerMb = 1024 * 1024;
  static const int bytesPerGb = 1024 * 1024 * 1024;

  static double toMb(int bytes) => bytes / bytesPerMb;
  static double toKb(int bytes) => bytes / bytesPerKb;
  static int mbToBytes(double mb) => (mb * bytesPerMb).round();
  static int kbToBytes(double kb) => (kb * bytesPerKb).round();
}

String formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }

  const units = ['KB', 'MB', 'GB', 'TB'];
  double value = bytes / 1024;
  var unitIndex = 0;

  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }

  return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} ${units[unitIndex]}';
}

