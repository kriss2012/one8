import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../../history/domain/entities/compression_history_item.dart';
import '../../controllers/image_compression_controller.dart';
import '../history_item_card.dart';

class HomeRecentsSection extends StatelessWidget {
  const HomeRecentsSection({
    required this.controller,
    required this.isDark,
    required this.onOpenHistory,
    required this.onOpenCompress,
    super.key,
  });

  final ImageCompressionController controller;
  final bool isDark;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenCompress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: AppSpacing.sm),
        StreamBuilder<List<CompressionHistoryItem>>(
          stream: controller.historyRepository.watchHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return _buildEmptyState(context)
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms)
                  .scale(
                    begin: const Offset(0.96, 0.96),
                    end: const Offset(1, 1),
                  );
            }

            final recentItems = history.take(3).toList();

            return Column(
              children: recentItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: HistoryItemCard(item: item)
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.1, end: 0),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recents',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            letterSpacing: -0.2,
          ),
        ),
        GestureDetector(
          onTap: onOpenHistory,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              'See All',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final btnBg = isDark ? Colors.white : AppColors.lightTextPrimary;
    final btnFg = isDark ? Colors.black : Colors.white;

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedTime02,
                color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No recent compressions',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Compressed files will appear here for instant access.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: onOpenCompress,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedAdd01,
                color: btnFg,
                size: 16,
              ),
              label: Text(
                'Start Compressing',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: btnFg,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBg,
                foregroundColor: btnFg,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
