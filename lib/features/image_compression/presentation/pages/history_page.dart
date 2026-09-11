import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

import '../../../../core/widgets/glass_card.dart';
import '../../../history/domain/entities/compression_history_item.dart';
import '../controllers/image_compression_controller.dart';
import '../widgets/history_item_card.dart';


class HistoryPage extends StatelessWidget {
  const HistoryPage({this.controller, super.key});

  final ImageCompressionController? controller;

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
          'Compression History',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: controller == null
            ? const SizedBox()
            : StreamBuilder<List<CompressionHistoryItem>>(
                stream: controller!.historyRepository.watchHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final history = snapshot.data ?? [];

                  if (history.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.xxl,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceHighlight
                                      : AppColors.lightSurfaceHighlight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder,
                                  ),
                                ),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedTime02,
                                  color: isDark
                                      ? AppColors.darkIcon
                                      : AppColors.lightIcon,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No Compression History',
                                style: AppTypography.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Files compressed in your sessions will be automatically displayed here.',
                                textAlign: TextAlign.center,
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 350.ms)
                          .scale(begin: const Offset(0.96, 0.96)),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.sm,
                      bottom: MediaQuery.of(context).padding.bottom + 100,
                    ),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: HistoryItemCard(item: item),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

