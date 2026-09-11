import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/byte_formatter.dart';
import '../../domain/entities/compression_preset.dart';
import '../controllers/image_compression_controller.dart';
import 'customization/compression_mode_selector.dart';
import 'customization/compression_scope_selector.dart';
import 'customization/customization_sheet_header.dart';
import 'customization/format_section.dart';
import 'customization/quality_section.dart';
import 'customization/target_size_section.dart';

class CompressionCustomizationBottomSheet extends StatefulWidget {
  const CompressionCustomizationBottomSheet({
    required this.controller,
    this.onStartCompress,
    super.key,
  });

  final ImageCompressionController controller;
  final VoidCallback? onStartCompress;

  static Future<void> show(
    BuildContext context,
    ImageCompressionController controller, {
    VoidCallback? onStartCompress,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => CompressionCustomizationBottomSheet(
        controller: controller,
        onStartCompress: onStartCompress,
      ),
    );
  }

  @override
  State<CompressionCustomizationBottomSheet> createState() =>
      _CompressionCustomizationBottomSheetState();
}

class _CompressionCustomizationBottomSheetState
    extends State<CompressionCustomizationBottomSheet> {
  int _modeIndex = 0; // 0: Target File Size, 1: Quality Percentage
  int _scopeIndex = 0; // 0: All Batch Items, 1: Selected File Only
  bool _isMB = true;
  double _targetValue = 1.0;
  late TextEditingController _targetSizeController;

  @override
  void initState() {
    super.initState();
    final preset = widget.controller.preset;
    final originalBytes = widget.controller.detectedOriginalBytes;

    if (preset.isTargetSizeMode) {
      _modeIndex = 0;
      final bytes = preset.targetSizeBytes!;
      if (bytes >= ByteConverter.bytesPerMb) {
        _isMB = true;
        _targetValue = ByteConverter.toMb(bytes).clamp(0.1, 100.0);
      } else {
        _isMB = false;
        _targetValue = ByteConverter.toKb(bytes).clamp(10.0, 10240.0);
      }
    } else {
      _modeIndex = 0;
      if (originalBytes > 0) {
        if (originalBytes >= ByteConverter.bytesPerMb) {
          _isMB = true;
          final originalMB = ByteConverter.toMb(originalBytes);
          _targetValue = (originalMB * 0.5).clamp(0.2, 50.0);
        } else {
          _isMB = false;
          final originalKB = ByteConverter.toKb(originalBytes);
          _targetValue = (originalKB * 0.5).clamp(20.0, 2048.0);
        }
      } else {
        _isMB = true;
        _targetValue = 1.0;
      }
    }

    _targetSizeController = TextEditingController(
      text: _targetValue % 1 == 0
          ? _targetValue.toInt().toString()
          : _targetValue.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _targetSizeController.dispose();
    super.dispose();
  }

  int get _computedTargetSizeBytes {
    return _isMB
        ? ByteConverter.mbToBytes(_targetValue)
        : ByteConverter.kbToBytes(_targetValue);
  }

  void _onTargetValueUpdated(double value) {
    setState(() {
      _targetValue = value;
      _targetSizeController.text = value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
    });
    widget.controller.updateTargetSizeBytes(_computedTargetSizeBytes);
  }

  void _onTargetTextSubmitted(String text) {
    final parsed = double.tryParse(text);
    if (parsed != null && parsed > 0) {
      setState(() {
        _targetValue = parsed;
      });
      widget.controller.updateTargetSizeBytes(_computedTargetSizeBytes);
    }
  }

  void _onUnitChanged(bool isMB) {
    if (_isMB == isMB) return;
    setState(() {
      _isMB = isMB;
      if (_isMB) {
        _targetValue = (_targetValue / 1024).clamp(0.1, 100.0);
      } else {
        _targetValue = (_targetValue * 1024).clamp(10.0, 10240.0);
      }
      _targetSizeController.text = _targetValue % 1 == 0
          ? _targetValue.toInt().toString()
          : _targetValue.toStringAsFixed(1);
    });
    widget.controller.updateTargetSizeBytes(_computedTargetSizeBytes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = widget.controller;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final preset = controller.preset;

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.98),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomizationSheetHeader(controller: controller, isDark: isDark),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scope Selector (Batch vs Selected file)
                        CompressionScopeSelector(
                          scopeIndex: _scopeIndex,
                          selectedCount: controller.selectedImages.length,
                          isDark: isDark,
                          onScopeChanged: (idx) => setState(() => _scopeIndex = idx),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Mode Selector (Target Size vs Quality %)
                        CompressionModeSelector(
                          modeIndex: _modeIndex,
                          isDark: isDark,
                          onModeChanged: (idx) {
                            setState(() => _modeIndex = idx);
                            if (idx == 0) {
                              controller.updateTargetSizeBytes(_computedTargetSizeBytes);
                            } else {
                              controller.updateQuality(preset.quality.toDouble());
                            }
                          },
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Mode Body
                        if (_modeIndex == 0)
                          TargetSizeSection(
                            targetValue: _targetValue,
                            isMB: _isMB,
                            isDark: isDark,
                            originalBytes: controller.detectedOriginalBytes,
                            controller: _targetSizeController,
                            onTargetValueUpdated: _onTargetValueUpdated,
                            onUnitChanged: _onUnitChanged,
                            onTargetTextSubmitted: _onTargetTextSubmitted,
                          )
                        else
                          QualitySection(
                            controller: controller,
                            preset: preset,
                            isDark: isDark,
                          ),

                        const SizedBox(height: AppSpacing.md),

                        // Target Format Selector
                        Text(
                          'Target Format',
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        FormatSection(
                          controller: controller,
                          preset: preset,
                          isDark: isDark,
                        ),

                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),

                  _buildApplyButton(context, isDark, controller, preset),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplyButton(
    BuildContext context,
    bool isDark,
    ImageCompressionController controller,
    CompressionPreset preset,
  ) {
    final labelText = preset.isTargetSizeMode
        ? 'Compress to ${preset.formattedTargetSize}'
        : 'Apply ${preset.quality}% Quality';

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onStartCompress?.call();
          },
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            color: isDark ? Colors.black : Colors.white,
            size: 20,
          ),
          label: Text(labelText),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : AppColors.lightTextPrimary,
            foregroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            textStyle: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
