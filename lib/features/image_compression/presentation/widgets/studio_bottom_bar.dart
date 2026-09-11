
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/image_compression_controller.dart';

class StudioBottomBar extends StatelessWidget {
  const StudioBottomBar({
    required this.controller,
    required this.onPickImages,
    required this.onCompressPressed,
    required this.onSaveAllPressed,
    super.key,
  });

  final ImageCompressionController controller;
  final VoidCallback onPickImages;
  final VoidCallback onCompressPressed;
  final VoidCallback onSaveAllPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasImages = controller.selectedImages.isNotEmpty;
    final isCompressing = controller.isCompressing;
    final isFinished = !isCompressing && controller.compressedImages.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Uses the Telegram-like surface color
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutExpo,
        padding: EdgeInsets.all(isCompressing ? AppSpacing.md : AppSpacing.xs + 2),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: isCompressing
              ? _buildProgressShower(context, isDark)
              : (isFinished
                  ? _buildSuccessShower(context, isDark)
                  : _buildIdleShower(context, isDark, hasImages)),
        ),
      ),
    );
  }

  // 1. IDLE COMMANDER
  // 1. IDLE COMMANDER
  Widget _buildIdleShower(BuildContext context, bool isDark, bool hasImages) {
    final fileCount = controller.selectedImages.length;
    final activeColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final fgColor = isDark ? Colors.black : Colors.white;

    return SizedBox(
      key: const ValueKey('idle_bar'),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: hasImages ? onCompressPressed : onPickImages,
        style: ElevatedButton.styleFrom(
          backgroundColor: activeColor,
          foregroundColor: fgColor,
          elevation: 0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36), // Match container curve
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: hasImages
                  ? HugeIcons.strokeRoundedSettings04
                  : HugeIcons.strokeRoundedFolderAdd,
              color: fgColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              hasImages
                  ? 'Compress $fileCount File${fileCount == 1 ? '' : 's'}'
                  : 'Choose Images',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. PHASE 2 CONVERSION SHOWER (Real-time progress)
  Widget _buildProgressShower(BuildContext context, bool isDark) {
    final progress = controller.progress;
    final completed = controller.completedCount;
    final total = controller.totalCount;
    final primaryAccent = isDark ? Colors.white : AppColors.lightTextPrimary;

    return SizedBox(
      key: const ValueKey('progress_bar'),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Processing $completed of $total',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: primaryAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
            ),
          ),
        ],
      ),
    );
  }

  // 3. PHASE 3 SUCCESS SHOWER
  Widget _buildSuccessShower(BuildContext context, bool isDark) {
    final totalOriginalBytes = controller.totalOriginalBytes;
    final totalCompressedBytes = controller.totalCompressedBytes;
    final bytesSaved = totalOriginalBytes - totalCompressedBytes;

    final savedMb = (bytesSaved / (1024 * 1024)).toStringAsFixed(1);
    final percentSaved = totalOriginalBytes > 0
        ? ((bytesSaved / totalOriginalBytes) * 100).clamp(0, 100).toInt()
        : 0;

    final btnBg = isDark ? Colors.white : AppColors.lightTextPrimary;
    final btnFg = isDark ? Colors.black : Colors.white;
    final primaryAccent = isDark ? Colors.white : AppColors.lightTextPrimary;

    return SizedBox(
      key: const ValueKey('success_bar'),
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                        color: primaryAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Success',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: primaryAccent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Saved $savedMb MB ($percentSaved%)',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onSaveAllPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnBg,
              foregroundColor: btnFg,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedDownload01,
                  color: btnFg,
                  size: 18,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Save All',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
