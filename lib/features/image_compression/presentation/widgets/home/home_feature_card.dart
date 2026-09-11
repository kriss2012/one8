import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/glass_card.dart';

class HomeFeatureCard extends StatelessWidget {
  const HomeFeatureCard({
    required this.title,
    required this.subtitle,
    required this.svgAssetPath,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
    this.badgeText,
    super.key,
  });

  final String title;
  final String subtitle;
  final String svgAssetPath;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 36),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: RadialGradient(
                center: const Alignment(0, -1.2),
                radius: 2.0,
                stops: const [0.0, 0.7],
                colors: [
                  accentColor.withValues(alpha: isDark ? 0.6 : 0.35),
                  Colors.transparent,
                ],
              ),
            ),
            child: Stack(
              children: [
                GlassCard(
                  onTap: onTap,
                  borderColor: Colors.transparent,
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm, 48, AppSpacing.sm, AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.5 : 0.4),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                        stops: const [0.0, 0.5],
                      ).createShader(bounds),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -6,
          child: SvgPicture.asset(
            svgAssetPath,
            width: 94,
            height: 94,
          ),
        ),
        if (badgeText != null)
          Positioned(
            top: 42,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
