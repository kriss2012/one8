import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/compression_preset.dart';
import '../../controllers/image_compression_controller.dart';

class QualitySection extends StatelessWidget {
  const QualitySection({
    required this.controller,
    required this.preset,
    required this.isDark,
    super.key,
  });

  final ImageCompressionController controller;
  final CompressionPreset preset;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quality Percentage',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${preset.quality}%',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: isDark ? Colors.white : AppColors.lightTextPrimary,
              inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
              thumbColor: isDark ? Colors.white : AppColors.lightTextPrimary,
              overlayColor: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: preset.quality.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              onChanged: (val) => controller.updateQuality(val),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildQualityPresetChip(
                CompressionPreset.light,
              ),
              const SizedBox(width: AppSpacing.xs),
              _buildQualityPresetChip(
                CompressionPreset.balanced,
              ),
              const SizedBox(width: AppSpacing.xs),
              _buildQualityPresetChip(
                CompressionPreset.aggressive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityPresetChip(CompressionPreset item) {
    final isSelected = preset.id == item.id;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectPreset(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
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
          child: Column(
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
              Text(
                '${item.quality}%',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? (isDark ? Colors.black87 : Colors.white70)
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
