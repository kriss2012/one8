import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/selected_image.dart';
import '../controllers/image_compression_controller.dart';

class HeroStageWorkspace extends StatefulWidget {
  const HeroStageWorkspace({
    required this.controller,
    required this.onPickImages,
    required this.onAddMoreImages,
    this.onTapImageItem,
    super.key,
  });

  final ImageCompressionController controller;
  final VoidCallback onPickImages;
  final VoidCallback onAddMoreImages;
  final ValueChanged<SelectedImage>? onTapImageItem;

  @override
  State<HeroStageWorkspace> createState() => _HeroStageWorkspaceState();
}

class _HeroStageWorkspaceState extends State<HeroStageWorkspace> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final images = widget.controller.selectedImages;

    if (images.isEmpty) {
      return _buildEmptyDropzone(context, isDark);
    }

    if (_activeIndex >= images.length) {
      _activeIndex = (images.length - 1).clamp(0, images.length);
    }

    final activeImage = images[_activeIndex];

    return Column(
      children: [
        // 1. HERO IMAGE CANVAS (55–60% of viewport height)
        Expanded(
          child: _buildHeroPreviewCard(context, activeImage, isDark),
        ),

        const SizedBox(height: AppSpacing.sm),

        // 2. HORIZONTAL THUMBNAIL BATCH REEL (Fixed 76px)
        _buildBatchThumbnailReel(context, images, isDark),
      ],
    );
  }

  Widget _buildHeroPreviewCard(BuildContext context, SelectedImage image, bool isDark) {
    final sizeMb = (image.originalBytes / (1024 * 1024)).toStringAsFixed(2);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Image Canvas
            Positioned.fill(
              child: Image.file(
                File(image.path),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HugeIcon(icon: HugeIcons.strokeRoundedAlert02, color: AppColors.error, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Unable to load preview',
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Top Glass Metadata Overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            image.format.name.toUpperCase(),
                            style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            image.fileName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$sizeMb MB',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Counter Badge (e.g. 1 of 3)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  '${_activeIndex + 1} of ${widget.controller.selectedImages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchThumbnailReel(BuildContext context, List<SelectedImage> images, bool isDark) {
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: images.length + 1,
        itemBuilder: (context, index) {
          if (index == images.length) {
            return _buildAddMoreButton(context, isDark);
          }

          final image = images[index];
          final isActive = index == _activeIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() => _activeIndex = index);
                widget.onTapImageItem?.call(image);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isActive
                            ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                            : (isDark ? Colors.white24 : Colors.black12),
                        width: isActive ? 2.5 : 1.0,
                      ),
                      boxShadow: const [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Delete Image Badge Button
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller.removeSelectedImage(image);
                        if (_activeIndex >= widget.controller.selectedImages.length) {
                          setState(() {
                            _activeIndex = (widget.controller.selectedImages.length - 1).clamp(0, widget.controller.selectedImages.length);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddMoreButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: widget.onAddMoreImages,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              color: AppColors.primary,
              size: 24,
            ),
            SizedBox(height: 2),
            Text(
              'Add',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDropzone(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: widget.onPickImages,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedImageAdd01,
                color: AppColors.primary,
                size: 40,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 1.0, end: 1.06, duration: 2.seconds, curve: Curves.easeInOutSine),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Select Image to Compress',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'JPEG, PNG, WebP & AVIF supported',
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
}
