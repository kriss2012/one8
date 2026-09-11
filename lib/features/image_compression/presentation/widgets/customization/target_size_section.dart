import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/byte_formatter.dart';

class TargetSizeSection extends StatelessWidget {
  const TargetSizeSection({
    required this.targetValue,
    required this.isMB,
    required this.isDark,
    required this.originalBytes,
    required this.controller,
    required this.onTargetValueUpdated,
    required this.onUnitChanged,
    required this.onTargetTextSubmitted,
    super.key,
  });

  final double targetValue;
  final bool isMB;
  final bool isDark;
  final int originalBytes;
  final TextEditingController controller;
  final ValueChanged<double> onTargetValueUpdated;
  final ValueChanged<bool> onUnitChanged;
  final ValueChanged<String> onTargetTextSubmitted;

  @override
  Widget build(BuildContext context) {
    final originalMB = originalBytes > 0 ? ByteConverter.toMb(originalBytes) : 20.0;
    final originalKB = originalBytes > 0 ? ByteConverter.toKb(originalBytes) : 20480.0;
    final maxSlider = isMB
        ? (originalMB * 1.2).clamp(10.0, 200.0)
        : (originalKB * 1.2).clamp(500.0, 50000.0);
    final minSlider = isMB ? 0.1 : 10.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Target Size',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              // Unit Switcher (MB / KB)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildUnitChip('MB', isMB, isDark),
                    _buildUnitChip('KB', !isMB, isDark),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Value Input & Display Box
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.12),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      suffixText: isMB ? 'MB' : 'KB',
                      suffixStyle: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                      ),
                    ),
                    onSubmitted: onTargetTextSubmitted,
                    onChanged: (val) {
                      final p = double.tryParse(val);
                      if (p != null && p > 0) {
                        onTargetValueUpdated(p);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: isDark ? Colors.white : AppColors.lightTextPrimary,
              inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
              thumbColor: isDark ? Colors.white : AppColors.lightTextPrimary,
              overlayColor: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: targetValue.clamp(minSlider, maxSlider).toDouble(),
              min: minSlider,
              max: maxSlider,
              onChanged: onTargetValueUpdated,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Quick Presets Chips
          _buildQuickTargetChips(isDark),
        ],
      ),
    );
  }

  Widget _buildUnitChip(String label, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () => onUnitChanged(label == 'MB'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : AppColors.lightTextPrimary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTargetChips(bool isDark) {
    final presets = isMB
        ? [0.5, 1.0, 2.0, 5.0, 10.0]
        : [100.0, 250.0, 500.0, 750.0, 1000.0];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((presetVal) {
        final isSelected = (targetValue - presetVal).abs() < 0.05;
        final label = presetVal % 1 == 0
            ? '${presetVal.toInt()} ${isMB ? 'MB' : 'KB'}'
            : '$presetVal ${isMB ? 'MB' : 'KB'}';

        return GestureDetector(
          onTap: () => onTargetValueUpdated(presetVal),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? Colors.white24 : Colors.black26),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
