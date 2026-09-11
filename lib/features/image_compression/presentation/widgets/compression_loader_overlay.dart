import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/image_compression_controller.dart';

class CompressionLoaderOverlay extends StatefulWidget {
  const CompressionLoaderOverlay({
    required this.controller,
    required this.onSuccessComplete,
    super.key,
  });

  final ImageCompressionController controller;
  final VoidCallback onSuccessComplete;

  static Future<void> show(
    BuildContext context,
    ImageCompressionController controller,
    VoidCallback onSuccessComplete,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => CompressionLoaderOverlay(
        controller: controller,
        onSuccessComplete: onSuccessComplete,
      ),
    );
  }

  @override
  State<CompressionLoaderOverlay> createState() => _CompressionLoaderOverlayState();
}

class _CompressionLoaderOverlayState extends State<CompressionLoaderOverlay> {
  bool _isSuccessState = false;
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    _successTimer?.cancel();
    super.dispose();
  }

  void _handleControllerChange() {
    if (!mounted) return;
    final controller = widget.controller;

    if (!controller.isCompressing && controller.compressedImages.isNotEmpty && !_isSuccessState) {
      setState(() {
        _isSuccessState = true;
      });

      // Play success checkmark animation for 700ms, then trigger navigation to Stage 4 Results
      _successTimer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss overlay dialog
          widget.onSuccessComplete(); // Open results screen
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progress = controller.progress;
    final completed = controller.completedCount;
    final total = controller.totalCount;
    final speed = controller.processingSpeedMBps.toStringAsFixed(1);
    final statusMsg = controller.statusMessage ?? 'Compressing media...';

    return PopScope(
      canPop: false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.90)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.md),

                // 1. ANIMATED INDICATOR CANVAS
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!_isSuccessState) ...[
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            value: progress > 0 ? progress : null,
                            strokeWidth: 7,
                            strokeCap: StrokeCap.round,
                            backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppTypography.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            color: isDark ? Colors.black : Colors.white,
                            size: 48,
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.4, 0.4),
                              end: const Offset(1.0, 1.0),
                              duration: 500.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(duration: 200.ms),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 2. STATUS TITLE
                Text(
                  _isSuccessState ? 'Compression Complete!' : 'Processing Images',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // 3. SUBTITLE TELEMETRY
                Text(
                  _isSuccessState
                      ? '${controller.compressedImages.length} image(s) optimized cleanly'
                      : 'Item $completed of $total • $speed MB/s',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // 4. CURRENT FILE BADGE
                if (!_isSuccessState)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 11,
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
