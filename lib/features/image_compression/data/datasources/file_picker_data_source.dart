import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/selected_image.dart';

class FilePickerDataSource {
  final ImagePicker _imagePicker = ImagePicker();

  Future<List<SelectedImage>> pickImages() async {
    // 1. Try FilePicker with FileType.custom (forces ACTION_GET_CONTENT with EXTRA_ALLOW_MULTIPLE on Android)
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic', 'bmp'],
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final images = _processFilePickerFiles(result.files);
        if (images.isNotEmpty) return images;
      }
    } catch (_) {}

    // 2. Try ImagePicker pickMultiImage() as second strategy
    try {
      final xFiles = await _imagePicker.pickMultiImage();
      if (xFiles.isNotEmpty) {
        final images = <SelectedImage>[];
        for (final xFile in xFiles) {
          final filePath = xFile.path;
          final imageFile = File(filePath);
          if (!await imageFile.exists()) continue;

          final bytes = await imageFile.length();
          final format = _resolveFormat(filePath);
          images.add(
            SelectedImage(
              path: filePath,
              fileName: xFile.name.isNotEmpty ? xFile.name : path.basename(filePath),
              originalBytes: bytes,
              format: format,
            ),
          );
        }
        if (images.isNotEmpty) return images;
      }
    } catch (_) {}

    // 3. Fallback to FilePicker with FileType.any (allows selecting multiple files of any extension)
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final imageFiles = result.files.where((f) {
          final ext = f.extension?.toLowerCase() ?? '';
          return ['jpg', 'jpeg', 'png', 'webp', 'heic', 'bmp'].contains(ext) ||
              f.path != null && _isImagePath(f.path!);
        }).toList();
        final images = _processFilePickerFiles(imageFiles);
        if (images.isNotEmpty) return images;
      }
    } catch (_) {}

    return const [];
  }

  List<SelectedImage> _processFilePickerFiles(List<PlatformFile> files) {
    final images = <SelectedImage>[];
    for (final file in files) {
      final pathStr = file.path;
      if (pathStr == null) continue;

      final imageFile = File(pathStr);
      if (!imageFile.existsSync()) continue;

      final bytes = imageFile.lengthSync();
      final format = _resolveFormat(pathStr);
      images.add(
        SelectedImage(
          path: pathStr,
          fileName: file.name,
          originalBytes: bytes,
          format: format,
        ),
      );
    }
    return images;
  }

  bool _isImagePath(String pathStr) {
    final lower = pathStr.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic') ||
        lower.endsWith('.bmp');
  }

  Future<String?> pickExportDirectory() {
    return FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose where to save compressed images',
    );
  }

  Future<String> getDefaultExportDirectory() async {
    Directory? baseDir;
    try {
      if (Platform.isAndroid) {
        final pictures = Directory('/storage/emulated/0/Pictures');
        if (await pictures.exists()) {
          baseDir = pictures;
        } else {
          final downloads = Directory('/storage/emulated/0/Download');
          if (await downloads.exists()) {
            baseDir = downloads;
          } else {
            baseDir = await getExternalStorageDirectory();
          }
        }
      } else if (Platform.isIOS) {
        baseDir = await getApplicationDocumentsDirectory();
      } else {
        baseDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      baseDir = await getApplicationDocumentsDirectory();
    }

    final folder = Directory(path.join(baseDir?.path ?? '.', 'ONE8'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder.path;
  }

  SupportedImageFormat _resolveFormat(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return SupportedImageFormat.jpeg;
    }
    if (lower.endsWith('.png')) {
      return SupportedImageFormat.png;
    }
    if (lower.endsWith('.webp')) {
      return SupportedImageFormat.webp;
    }
    return SupportedImageFormat.unsupported;
  }
}

class FilePickerFailure extends AppFailure {
  const FilePickerFailure(super.message, {super.details});
}
