import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class CompressionModeSelector extends StatelessWidget {
  const CompressionModeSelector({
    required this.modeIndex,
    required this.isDark,
    required this.onModeChanged,
    super.key,
  });

  final int modeIndex;
  final bool isDark;
  final ValueChanged<int> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark ? Colors.white : AppColors.lightTextPrimary;
    final activeText = isDark ? Colors.black : Colors.white;
    final inactiveText = isDark ? Colors.white70 : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: modeIndex == 0 ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedTarget02,
                      color: modeIndex == 0 ? activeText : inactiveText,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Target File Size',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: modeIndex == 0 ? activeText : inactiveText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: modeIndex == 1 ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSparkles,
                      color: modeIndex == 1 ? activeText : inactiveText,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Quality %',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: modeIndex == 1 ? activeText : inactiveText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
