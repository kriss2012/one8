import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class FormatChipSelector extends StatelessWidget {
  const FormatChipSelector({
    super.key,
    this.selectedType = CompressMediaType.image,
    this.onSelectType,
  });

  final CompressMediaType selectedType;
  final ValueChanged<CompressMediaType>? onSelectType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _buildChip(
            context: context,
            isDark: isDark,
            type: CompressMediaType.image,
            label: 'Images',
            icon: HugeIcons.strokeRoundedImage01,
            isActive: selectedType == CompressMediaType.image,
            isAvailable: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildChip(
            context: context,
            isDark: isDark,
            type: CompressMediaType.video,
            label: 'Videos',
            icon: HugeIcons.strokeRoundedVideo01,
            isActive: selectedType == CompressMediaType.video,
            isAvailable: false,
            badge: 'SOON',
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildChip(
            context: context,
            isDark: isDark,
            type: CompressMediaType.audio,
            label: 'Audio',
            icon: HugeIcons.strokeRoundedVolumeHigh,
            isActive: selectedType == CompressMediaType.audio,
            isAvailable: false,
            badge: 'SOON',
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildChip(
            context: context,
            isDark: isDark,
            type: CompressMediaType.document,
            label: 'Docs',
            icon: HugeIcons.strokeRoundedFile01,
            isActive: selectedType == CompressMediaType.document,
            isAvailable: false,
            badge: 'SOON',
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required bool isDark,
    required CompressMediaType type,
    required String label,
    required List<List<dynamic>> icon,
    required bool isActive,
    required bool isAvailable,
    String? badge,
  }) {
    final activeBg = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final activeFg = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final inactiveBg = isDark
        ? AppColors.darkSurfaceHighlight
        : AppColors.lightSurfaceHighlight;
    final inactiveFg = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: () {
        if (isAvailable) {
          onSelectType?.call(type);
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('$label compression arriving in v2.0.'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 1500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
            width: 0.8,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.black).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedTheme(
              data: ThemeData(
                iconTheme: IconThemeData(
                  color: isActive ? activeFg : inactiveFg,
                ),
              ),
              child: HugeIcon(
                icon: icon,
                color: isActive ? activeFg : inactiveFg,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: isActive ? activeFg : inactiveFg,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.1,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum CompressMediaType {
  image,
  video,
  audio,
  document,
}
