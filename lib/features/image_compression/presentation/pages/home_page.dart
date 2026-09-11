import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controllers/image_compression_controller.dart';
import '../widgets/home/home_feature_card.dart';
import '../widgets/home/home_header_widget.dart';
import '../widgets/home/home_recents_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.controller,
    required this.onOpenCompress,
    required this.onOpenHistory,
    super.key,
  });

  final ImageCompressionController controller;
  final VoidCallback onOpenCompress;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: MediaQuery.of(context).padding.bottom + 100, // Floating nav bar padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER
              HomeHeaderWidget(controller: controller, isDark: isDark)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, end: 0),

              const SizedBox(height: AppSpacing.xl),

              // 2. FEATURE CARDS (2-Column Grid)
              Row(
                children: [
                  Expanded(
                    child: HomeFeatureCard(
                      title: 'Compress',
                      subtitle: 'Reduce size, retain high quality',
                      svgAssetPath: 'assets/svg/compress_engine.svg',
                      accentColor: AppColors.accentBlue,
                      isDark: isDark,
                      onTap: onOpenCompress,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: HomeFeatureCard(
                      title: 'Resize',
                      subtitle: 'Scale dimensions precisely',
                      svgAssetPath: 'assets/svg/resize_engine.svg',
                      accentColor: Colors.amber,
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.xxl),

              // 3. RECENTS SECTION
              HomeRecentsSection(
                controller: controller,
                isDark: isDark,
                onOpenHistory: onOpenHistory,
                onOpenCompress: onOpenCompress,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
