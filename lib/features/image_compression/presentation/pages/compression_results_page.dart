import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/byte_formatter.dart';
import '../../domain/entities/compressed_image.dart';
import '../controllers/image_compression_controller.dart';
import '../widgets/image_preview_modal.dart';

class CompressionResultsPage extends StatelessWidget {
  const CompressionResultsPage({
    required this.controller,
    super.key,
  });

  final ImageCompressionController controller;

  static void navigate(BuildContext context, ImageCompressionController controller) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CompressionResultsPage(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final results = controller.compressedImages;

    final totalOriginal = controller.totalOriginalBytes;
    final totalCompressed = controller.totalCompressedBytes;
    final bytesSaved = (totalOriginal - totalCompressed).clamp(0, totalOriginal);
    final savedPct = controller.savedPercentage;
    final elapsedMs = controller.elapsedMilliseconds;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Compression Summary',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // 1. HERO SAVINGS METRICS CARD
                    _buildHeroMetricsCard(context, isDark, totalOriginal, totalCompressed, bytesSaved, savedPct, elapsedMs)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.05, end: 0),

                    const SizedBox(height: AppSpacing.lg),

                    // 2. SECTION HEADER
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Compressed Files (${results.length})',
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // 3. COMPRESSED IMAGES LIST
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _buildCompressedItemCard(context, item, isDark)
                              .animate()
                              .fadeIn(delay: (100 * index).ms, duration: 350.ms)
                              .slideY(begin: 0.04, end: 0),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // 4. BOTTOM ACTION BAR (Save All & Share All)
            _buildBottomActionBar(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroMetricsCard(
    BuildContext context,
    bool isDark,
    int originalBytes,
    int compressedBytes,
    int savedBytes,
    double savedPct,
    int elapsedMs,
  ) {
    final savedMb = (savedBytes / (1024 * 1024)).toStringAsFixed(1);
    final origMb = formatBytes(originalBytes);
    final compMb = formatBytes(compressedBytes);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL SAVINGS',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$savedMb MB',
                    style: AppTypography.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '-${savedPct.toStringAsFixed(0)}%',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricStat('Original', origMb, isDark),
              _buildMetricStat('Compressed', compMb, isDark),
              _buildMetricStat('Duration', '${elapsedMs}ms', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricStat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompressedItemCard(BuildContext context, CompressedImage item, bool isDark) {
    final origMb = formatBytes(item.originalBytes);
    final compMb = formatBytes(item.compressedBytes);
    final itemSavedPct = item.originalBytes > 0
        ? (((item.originalBytes - item.compressedBytes) / item.originalBytes) * 100).clamp(0, 100).toInt()
        : 0;

    return GestureDetector(
      onTap: () => ImagePreviewModal.show(context, item.source, controller),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.7)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Image.file(
                  File(item.outputPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.outputFileName,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$origMb ➔ $compMb',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-$itemSavedPct%',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const HugeIcon(
              icon: HugeIcons.strokeRoundedView,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, bool isDark) {
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
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _handleSaveAll(context),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedDownload01,
                  color: isDark ? Colors.black : Colors.white,
                  size: 20,
                ),
                label: const Text('Save All to Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : AppColors.lightTextPrimary,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  textStyle: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveAll(BuildContext context) async {
    final savePath = await controller.saveCompressedImages();
    if (!context.mounted) return;
    if (savePath != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle02, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Saved ${controller.compressedImages.length} image(s) to ONE8 folder!',
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
    }
  }
}
