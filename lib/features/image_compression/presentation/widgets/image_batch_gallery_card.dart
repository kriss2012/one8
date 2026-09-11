import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/selected_image.dart';
import '../controllers/image_compression_controller.dart';
import 'compression_customization_bottom_sheet.dart';
import 'image_preview_modal.dart';

class ImageBatchGalleryCard extends StatelessWidget {
  const ImageBatchGalleryCard({
    required this.controller,
    super.key,
  });

  final ImageCompressionController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final images = controller.selectedImages;
    final totalBytes = controller.totalOriginalBytes;
    final totalMb = (totalBytes / (1024 * 1024)).toStringAsFixed(2);

    final detectedBatchFormat = _getBatchFormatLabel(images);
    final monoColor = isDark ? Colors.white : AppColors.lightTextPrimary;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BATCH HEADER & DETECTED FORMAT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Detected Format Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: monoColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            detectedBatchFormat,
                            style: AppTypography.textTheme.labelMedium?.copyWith(
                              color: monoColor,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Batch Gallery',
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            '${images.length} file${images.length == 1 ? '' : 's'} • $totalMb MB',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ACTION BUTTONS: Add More & Tune Customization Button
              Row(
                children: [
                  // Add More Button
                  TextButton.icon(
                    onPressed: controller.addMoreImages,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      color: monoColor,
                      size: 16,
                    ),
                    label: const Text('Add More'),
                    style: TextButton.styleFrom(
                      foregroundColor: monoColor,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Customization Button (Tune Settings Modal Trigger)
                  Tooltip(
                    message: 'Tune Batch Settings',
                    child: InkWell(
                      onTap: () => CompressionCustomizationBottomSheet.show(context, controller),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs + 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedSettings01,
                          color: monoColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. GALLERY GRID / LIST
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              final crossAxisCount = isWide ? 4 : 3;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.xs + 2,
                  mainAxisSpacing: AppSpacing.xs + 2,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final item = images[index];
                  final mb = (item.originalBytes / (1024 * 1024)).toStringAsFixed(1);
                  final formatName = item.format.badgeName;

                  return GestureDetector(
                    onTap: () => ImagePreviewModal.show(context, item, controller),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Thumbnail Image
                          Image.file(
                            File(item.path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: isDark ? Colors.white10 : Colors.black12,
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),

                          // Top Gradient Overlay
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 36,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.54),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Bottom Gradient Overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 36,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Format Badge (Top Left)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getFormatBadgeColor(item.format),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                formatName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),

                          // Delete Icon (Top Right)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => controller.removeSelectedImage(item),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // File Size Pill (Bottom Left)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Text(
                              '$mb MB',
                              style: AppTypography.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                shadows: const [
                                  Shadow(blurRadius: 4, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
                },
              );
            },
          ),
        ],
      ),
    );
  }

  static String _getBatchFormatLabel(List<SelectedImage> images) {
    if (images.isEmpty) return 'IMAGES';
    final firstFormat = images.first.format;
    final isUniform = images.every((img) => img.format == firstFormat);

    if (isUniform) {
      return '${firstFormat.badgeName} BATCH';
    }
    return 'IMAGE BATCH';
  }

  static Color _getFormatBadgeColor(SupportedImageFormat format) {
    return const Color(0xFF27272A); // Monochrome Dark Charcoal Pill
  }
}
