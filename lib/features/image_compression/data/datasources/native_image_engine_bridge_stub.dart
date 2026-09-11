import '../../../../src/rust/api/image_engine.dart' as frb;

class NativeImageEngineBridge {
  const NativeImageEngineBridge._();

  static const instance = NativeImageEngineBridge._();

  bool get isSupportedPlatform => false;
  bool get isAvailable => false;

  Future<NativeCompressionResponse> compress({
    required String id,
    required String inputPath,
    required String outputPath,
    required int quality,
    required int pngLevel,
    required frb.ResizeMode resizeMode,
    required frb.OutputFormat outputFormat,
    BigInt? targetSizeBytes,
  }) {
    throw UnsupportedError(
      'Native image engine is not available on this platform.',
    );
  }

  Stream<frb.CompressionTaskProgress> compressStream({
    required List<frb.CompressionRequest> requests,
  }) {
    throw UnsupportedError(
      'Native image engine is not available on this platform.',
    );
  }
}

class NativeCompressionResponse {
  const NativeCompressionResponse({
    required this.id,
    required this.outputPath,
    required this.originalBytes,
    required this.compressedBytes,
    required this.width,
    required this.height,
    required this.format,
  });

  final String id;
  final String outputPath;
  final int originalBytes;
  final int compressedBytes;
  final int width;
  final int height;
  final String format;
}
