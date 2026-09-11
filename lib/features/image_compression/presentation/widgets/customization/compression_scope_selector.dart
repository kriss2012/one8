import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class CompressionScopeSelector extends StatelessWidget {
  const CompressionScopeSelector({
    required this.scopeIndex,
    required this.selectedCount,
    required this.isDark,
    required this.onScopeChanged,
    super.key,
  });

  final int scopeIndex;
  final int selectedCount;
  final bool isDark;
  final ValueChanged<int> onScopeChanged;

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark ? Colors.white : AppColors.lightTextPrimary;
    final activeText = isDark ? Colors.black : Colors.white;
    final inactiveText = isDark ? Colors.white70 : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onScopeChanged(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scopeIndex == 0 ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'All Files ($selectedCount)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scopeIndex == 0 ? activeText : inactiveText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onScopeChanged(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scopeIndex == 1 ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'Selected Only',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scopeIndex == 1 ? activeText : inactiveText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
