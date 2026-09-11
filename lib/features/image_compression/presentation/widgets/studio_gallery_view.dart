import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/selected_image.dart';
import '../controllers/image_compression_controller.dart';
import 'compression_customization_bottom_sheet.dart';

class StudioGalleryView extends StatelessWidget {
  const StudioGalleryView({
    required this.controller,
    required this.onPickImages,
    this.onTapImageItem,
    super.key,
  });

  final ImageCompressionController controller;
  final VoidCallback onPickImages;
  final ValueChanged<SelectedImage>? onTapImageItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final images = controller.selectedImages;
    final compressedImages = controller.compressedImages;
    final isCompressing = controller.isCompressing;

    if (images.isEmpty) {
      return _buildEmptyDropzone(context, isDark);
    }

    final totalBytes = controller.totalOriginalBytes;
    final totalMb = (totalBytes / (1024 * 1024)).toStringAsFixed(2);
    final detectedFormat = _getBatchFormatLabel(images);
    final formatColor = _getBatchFormatColor(images, isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. GALLERY HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: formatColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: formatColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      detectedFormat,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: formatColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${images.length} item${images.length == 1 ? '' : 's'} • $totalMb MB',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: isCompressing ? null : () => CompressionCustomizationBottomSheet.show(context, controller),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings01,
                  color: isCompressing
                      ? (isDark ? Colors.white30 : Colors.black26)
                      : (isDark ? Colors.white : Colors.black87),
                  size: 20,
                ),
                tooltip: 'Tune Batch Settings',
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // 2. GALLERY GRID WITH INTEGRATED (+) ADD MORE CARD
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 500 ? 4 : 3;
            // Grid items = images.length + 1 for the trailing "+" card
            final totalGridCount = images.length + 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalGridCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                // Last Index is the "+" Add More Card
                if (index == images.length) {
                  return _buildAddMoreGridCard(context, isDark, isCompressing);
                }

                final item = images[index];
                final isItemCompressed = compressedImages.any((img) => img.source.path == item.path);
                final compressedItem = isItemCompressed
                    ? compressedImages.firstWhere((img) => img.source.path == item.path)
                    : null;

                return _buildImageGridCard(
                  context: context,
                  isDark: isDark,
                  item: item,
                  isCompressing: isCompressing,
                  isCompressed: isItemCompressed,
                  compressedSizeMb: compressedItem != null
                      ? (compressedItem.compressedBytes / (1024 * 1024)).toStringAsFixed(1)
                      : null,
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ORGANIC EMPTY STATE DROPZONE
  Widget _buildEmptyDropzone(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: onPickImages,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl * 1.5,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedImageAdd01,
                color: AppColors.primary,
                size: 32,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 1.0, end: 1.05, duration: 2.seconds, curve: Curves.easeInOutSine),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Drop media here',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'JPEG, PNG, WebP & AVIF',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MINIMALIST TRAILING (+) ADD MORE CARD
  Widget _buildAddMoreGridCard(BuildContext context, bool isDark, bool isCompressing) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isCompressing ? 0.3 : 1.0,
      child: GestureDetector(
        onTap: isCompressing ? null : controller.addMoreImages,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              color: isDark ? Colors.white60 : Colors.black45,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  // PREMIUM IMAGE THUMBNAIL ITEM
  Widget _buildImageGridCard({
    required BuildContext context,
    required bool isDark,
    required SelectedImage item,
    required bool isCompressing,
    required bool isCompressed,
    String? compressedSizeMb,
  }) {
    final origMb = (item.originalBytes / (1024 * 1024)).toStringAsFixed(1);
    final formatName = item.format.badgeName;

    // Visual state opacity during compression (Phase 2 core logic)
    final double itemOpacity = isCompressing && !isCompressed ? 0.35 : 1.0;

    Widget card = AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: itemOpacity,
      curve: Curves.easeOutCubic,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompressed
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: isCompressed ? 1.5 : 0,
          ),
          boxShadow: isCompressed && isDark
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Thumbnail Image
              Image.file(
                File(item.path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: isDark ? Colors.white10 : Colors.black12,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),

              // 2. Subtle Dark Gradient Overlay for Contrast
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Minimal Format Badge (Top Left)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    formatName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // 4. Clean Delete Action (Top Right)
              if (!isCompressing)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => controller.removeSelectedImage(item),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // 5. High-end Dark Glass Completion Badge
              if (isCompressed)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.70),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),

              // 6. Size Tag (Bottom Left) - Crisp White with Contrast Shadow
              Positioned(
                bottom: 8,
                left: 8,
                child: Text(
                  isCompressed && compressedSizeMb != null
                      ? '$compressedSizeMb MB'
                      : '$origMb MB',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.3,
                    shadows: [
                      Shadow(color: Colors.black87, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Apply the "Completion Pop" animation when it just finishes compressing.
    // We only trigger this if the widget was previously NOT compressed but now IS compressed.
    // Using flutter_animate's key helps trigger it once.
    if (isCompressed) {
      card = card.animate(key: ValueKey('compressed_${item.path}'))
          .scaleXY(begin: 0.94, end: 1.0, duration: 400.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 200.ms);
    }

    return GestureDetector(
      onTap: () {
        if (!isCompressing) {
          onTapImageItem?.call(item);
        }
      },
      child: card,
    );
  }

  static String _getBatchFormatLabel(List<SelectedImage> images) {
    if (images.isEmpty) return 'IMAGES';
    final firstFormat = images.first.format;
    final isUniform = images.every((img) => img.format == firstFormat);

    if (isUniform) {
      return firstFormat.badgeName;
    }
    return 'MIXED';
  }

  static Color _getBatchFormatColor(List<SelectedImage> images, bool isDark) {
    return AppColors.primary;
  }
}
