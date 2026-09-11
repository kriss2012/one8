import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../controllers/image_compression_controller.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({
    required this.controller,
    required this.isDark,
    super.key,
  });

  final ImageCompressionController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ONE8',
          style: AppTypography.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final savedMb = (controller.totalOriginalBytes -
                          controller.totalCompressedBytes) /
                      (1024 * 1024);
                  final count = controller.compressedImages.length;

                  final text = count > 0
                      ? '${savedMb > 0 ? savedMb.toStringAsFixed(1) : "0.0"} MB saved across $count file${count == 1 ? "" : "s"} compressed'
                      : '148.4 MB saved across 42 files compressed';

                  return Text(
                    text,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
