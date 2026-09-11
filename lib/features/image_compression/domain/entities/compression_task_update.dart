import '../../../../core/errors/app_failure.dart';
import 'compressed_image.dart';
import 'selected_image.dart';

class CompressionTaskUpdate {
  const CompressionTaskUpdate({
    required this.total,
    required this.completed,
    this.currentImageName,
    this.result,
    this.failure,
    this.source,
  });

  final int total;
  final int completed;
  final String? currentImageName;
  final CompressedImage? result;
  final AppFailure? failure;
  final SelectedImage? source;

  double get progress => total == 0 ? 0 : completed / total;
}
