import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class RibbonBadge extends StatelessWidget {
  const RibbonBadge({
    required this.child,
    required this.text,
    super.key,
    this.borderRadius = 20.0,
  });

  final Widget child;
  final String text;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          child,
          Positioned(
            top: 14,
            right: -32,
            child: Transform.rotate(
              angle: math.pi / 4, // ~45 degrees
              child: Container(
                width: 110,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.accentWarning,
                ),
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 10,
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
