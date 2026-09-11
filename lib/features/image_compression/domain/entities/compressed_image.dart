import 'selected_image.dart';

class CompressedImage {
  const CompressedImage({
    required this.source,
    required this.outputPath,
    required this.outputFileName,
    required this.originalBytes,
    required this.compressedBytes,
  });

  final SelectedImage source;
  final String outputPath;
  final String outputFileName;
  final int originalBytes;
  final int compressedBytes;

  double get savingsRatio {
    if (originalBytes == 0) {
      return 0;
    }

    return 1 - (compressedBytes / originalBytes);
  }

  double get savedPercentage => (savingsRatio * 100).clamp(0, 100);
}
