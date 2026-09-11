import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/compression_preset.dart';
import '../controllers/image_compression_controller.dart';
import 'resize_settings_widget.dart';

class CompressionSettingsCard extends StatelessWidget {
  const CompressionSettingsCard({required this.controller, super.key});

  final ImageCompressionController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preset = controller.preset;
    final isDark = theme.brightness == Brightness.dark;

    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedSettings02, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('Quality & Format', style: AppTypography.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Preset', style: AppTypography.textTheme.labelLarge?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: CompressionPreset.defaults
                .map(
                  (option) => ChoiceChip(
                    label: Text(option.label),
                    selected: preset.id == option.id,
                    onSelected: (_) => controller.selectPreset(option),
                    showCheckmark: false,
                    selectedColor: AppColors.primary.withAlpha(25),
                    labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: preset.id == option.id ? AppColors.primary : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      fontWeight: preset.id == option.id ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quality Level', style: AppTypography.textTheme.bodyLarge),
              Text('${preset.quality}%', style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withAlpha(30),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: preset.quality.toDouble(),
              min: 40,
              max: 98,
              divisions: 29,
              onChanged: controller.updateQuality,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Output Format', style: AppTypography.textTheme.bodyLarge),
              DropdownButton<TargetFormat>(
                value: preset.targetFormat,
                underline: const SizedBox(),
                icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01, size: 16, color: isDark ? AppColors.darkIcon : AppColors.lightIcon),
                style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
                items: const [
                  DropdownMenuItem(value: TargetFormat.auto, child: Text('Auto')),
                  DropdownMenuItem(value: TargetFormat.jpeg, child: Text('JPEG')),
                  DropdownMenuItem(value: TargetFormat.png, child: Text('PNG')),
                  DropdownMenuItem(value: TargetFormat.webp, child: Text('WebP')),
                ],
                onChanged: (val) {
                  if (val != null) controller.updateTargetFormat(val);
                },
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          ResizeSettingsWidget(controller: controller),
        ],
      ),
    );
  }
}
