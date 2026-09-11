import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../controllers/image_compression_controller.dart';

class CustomizationSheetHeader extends StatelessWidget {
  const CustomizationSheetHeader({
    required this.controller,
    required this.isDark,
    super.key,
  });

  final ImageCompressionController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final imageCount = controller.selectedImages.length;
    final subtitle = imageCount == 0
        ? 'Set target size or quality'
        : 'Selected: $imageCount file${imageCount == 1 ? '' : 's'} (${controller.detectedOriginalSizeFormatted})';

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? Colors.white30 : Colors.black26,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compression Settings',
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: AppColors.lightIcon,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
