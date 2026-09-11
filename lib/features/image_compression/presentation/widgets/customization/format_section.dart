import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/compression_preset.dart';
import '../../controllers/image_compression_controller.dart';

class FormatSection extends StatelessWidget {
  const FormatSection({
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
    return Row(
      children: TargetFormat.values.map((fmt) {
        final isSelected = preset.targetFormat == fmt;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => controller.updateTargetFormat(fmt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? Colors.white24 : Colors.black26),
                  ),
                ),
                child: Text(
                  fmt.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
