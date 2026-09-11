enum SupportedImageFormat { jpeg, png, webp, unsupported }

extension SupportedImageFormatX on SupportedImageFormat {
  String get badgeName {
    switch (this) {
      case SupportedImageFormat.jpeg:
        return 'JPG';
      case SupportedImageFormat.png:
        return 'PNG';
      case SupportedImageFormat.webp:
        return 'WEBP';
      case SupportedImageFormat.unsupported:
        return 'IMG';
    }
  }

  String get fullName {
    switch (this) {
      case SupportedImageFormat.jpeg:
        return 'JPEG Image';
      case SupportedImageFormat.png:
        return 'PNG Image';
      case SupportedImageFormat.webp:
        return 'WebP Image';
      case SupportedImageFormat.unsupported:
        return 'Unknown Image';
    }
  }
}

class SelectedImage {
  const SelectedImage({
    required this.path,
    required this.fileName,
    required this.originalBytes,
    required this.format,
  });

  final String path;
  final String fileName;
  final int originalBytes;
  final SupportedImageFormat format;
}
