import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.sm,
            bottom: MediaQuery.of(context).padding.bottom + 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Engine Status Header Card
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceHighlight
                            : AppColors.lightSurfaceHighlight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedCpu,
                          color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local Engine',
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rust FFI Turbo Engine • Active',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'PREFERENCES',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingRow(
                      context,
                      icon: HugeIcons.strokeRoundedCpu,
                      title: 'Compression Engine',
                      subtitle: 'Native Rust Rayon Multi-threading',
                      trailingText: 'v2.1',
                      isDark: isDark,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingRow(
                      context,
                      icon: HugeIcons.strokeRoundedImage01,
                      title: 'Default Format',
                      subtitle: 'Auto-detect best format',
                      trailingText: 'WebP',
                      isDark: isDark,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingRow(
                      context,
                      icon: HugeIcons.strokeRoundedFolder01,
                      title: 'Save Destination',
                      subtitle: 'Prompt every time',
                      trailingText: 'System Picker',
                      isDark: isDark,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'ABOUT',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingRow(
                      context,
                      icon: HugeIcons.strokeRoundedInformationCircle,
                      title: 'ONE8 Version',
                      subtitle: 'Fast. Private. Local.',
                      trailingText: 'v1.1.0',
                      isDark: isDark,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingRow(
                      context,
                      icon: HugeIcons.strokeRoundedUser,
                      title: 'Maintainer',
                      subtitle: 'Krishna Patil',
                      trailingText: 'kriss2012',
                      isDark: isDark,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingRow(
                      context,
                      icon: HugeIcons.strokeRoundedGitBranch,
                      title: 'Repository',
                      subtitle: 'github.com/kriss2012/one8',
                      trailingText: 'GitHub',
                      isDark: isDark,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingRow(
                      context,
                      icon: HugeIcons.strokeRoundedLicense,
                      title: 'License',
                      subtitle: 'MIT Open Source License',
                      trailingText: 'MIT',
                      isDark: isDark,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 350.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    required String trailingText,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: HugeIcon(
              icon: icon,
              color: isDark ? Colors.white70 : Colors.black87,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailingText,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
