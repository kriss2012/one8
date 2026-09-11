import 'package:flutter/material.dart';

import 'package:hugeicons/hugeicons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ActionTile extends StatelessWidget {
  const ActionTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.showDivider = true,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<List<dynamic>> icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final disabled = onTap == null;
    final textColor = disabled 
        ? (isDark ? AppColors.darkIcon : AppColors.lightIcon)
        : (destructive ? AppColors.error : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary));

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: disabled ? (isDark ? Colors.white10 : Colors.black12) : iconColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: HugeIcon(
                    icon: icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (trailing != null)
                  trailing!
                else
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
                    size: 20,
                  ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 0.5,
              indent: AppSpacing.md,
              endIndent: AppSpacing.md,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
        ],
      ),
    );
  }
}
