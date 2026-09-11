import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/section_card.dart';
import '../controllers/image_compression_controller.dart';

// ─── Progress Card ─────────────────────────────────────────────────────────────
// StatefulWidget so we own an AnimationController for butter-smooth progress.
// The controller.progress value is driven from the Dart side at ≤60fps.
// We interpolate from the CURRENT animated value to the new target,
// so even a jump from 0.3 to 0.8 (fast Rust batch) looks smooth.

class CompressionProgressCard extends StatefulWidget {
  const CompressionProgressCard({required this.controller, super.key});

  final ImageCompressionController controller;

  @override
  State<CompressionProgressCard> createState() => _CompressionProgressCardState();
}

class _CompressionProgressCardState extends State<CompressionProgressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressAnim;
  late final Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _progressValue = CurvedAnimation(
      parent: _progressAnim,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(CompressionProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animateToCurrentProgress();
  }

  void _animateToCurrentProgress() {
    final target = widget.controller.isCompressing ? widget.controller.progress : 1.0;
    // Animate FROM current animated value TO target — no reset to 0.
    _progressAnim.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _progressAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ctrl = widget.controller;
    final isCompressing = ctrl.isCompressing;

    // Trigger animation whenever we rebuild (parent notified via ChangeNotifier)
    _animateToCurrentProgress();

    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ────────────────────────────────────────────────────
          Row(
            children: [
              // Animated flash icon while compressing
              if (isCompressing)
                HugeIcon(icon: HugeIcons.strokeRoundedFlash, color: AppColors.warning, size: 18)
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1800.ms)
              else
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: AppColors.success,
                  size: 18,
                ).animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  isCompressing ? 'Compressing…' : 'Complete',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Cancel button
              if (isCompressing)
                GestureDetector(
                  onTap: ctrl.cancelCompression,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(25),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 13, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          'Cancel',
                          style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Counter Row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCompressing
                    ? '${ctrl.completedCount} / ${ctrl.totalCount} images'
                    : '${ctrl.compressedImages.length} images compressed',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              // Animated percentage counter
              AnimatedBuilder(
                animation: _progressValue,
                builder: (context, _) {
                  final pct = (_progressValue.value * 100).round();
                  return Text(
                    '$pct%',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // ── Smooth Animated Progress Bar ──────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: AnimatedBuilder(
              animation: _progressValue,
              builder: (context, _) {
                return LinearProgressIndicator(
                  value: _progressValue.value,
                  minHeight: 7,
                  backgroundColor: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    // Color shifts from primary → success as it completes
                    Color.lerp(AppColors.primary, AppColors.success, _progressValue.value)!,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Status Message ────────────────────────────────────────────────
          Text(
            ctrl.statusMessage ?? 'Waiting for your next batch.',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // ── Real-Time Telemetry Row ────────────────────────────────────────
          if (ctrl.elapsedMilliseconds > 0 || ctrl.processingSpeedMBps > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                // Elapsed time
                if (ctrl.elapsedMilliseconds > 0)
                  _TelemetryChip(
                    icon: HugeIcons.strokeRoundedTimer02,
                    label: _formatDuration(ctrl.elapsedMilliseconds),
                    color: AppColors.info,
                  ),
                // Throughput
                if (ctrl.processingSpeedMBps > 0)
                  _TelemetryChip(
                    icon: HugeIcons.strokeRoundedDashboardSpeed01,
                    label: '${ctrl.processingSpeedMBps.toStringAsFixed(1)} MB/s',
                    color: AppColors.primary,
                  ),
                // ETA
                if (ctrl.estimatedSecondsRemaining != null && ctrl.isCompressing)
                  _TelemetryChip(
                    icon: HugeIcons.strokeRoundedClock01,
                    label: '~${_formatEta(ctrl.estimatedSecondsRemaining!)} left',
                    color: AppColors.warning,
                  ),
                // Savings ratio (when done)
                if (!ctrl.isCompressing && ctrl.savedPercentage > 0)
                  _TelemetryChip(
                    icon: HugeIcons.strokeRoundedArrowDown01,
                    label: '${ctrl.savedPercentage.toStringAsFixed(1)}% saved',
                    color: AppColors.success,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Telemetry Chip ────────────────────────────────────────────────────────────

class _TelemetryChip extends StatelessWidget {
  const _TelemetryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final List<List<dynamic>> icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 30 : 18),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _formatDuration(int ms) {
  if (ms < 1000) return '${ms}ms';
  final sec = ms / 1000;
  if (sec < 60) return '${sec.toStringAsFixed(1)}s';
  final m = (sec ~/ 60);
  final s = (sec % 60).round();
  return '${m}m ${s}s';
}

String _formatEta(double seconds) {
  if (seconds < 1) return '<1s';
  if (seconds < 60) return '${seconds.round()}s';
  final m = (seconds ~/ 60);
  final s = (seconds % 60).round();
  return '${m}m ${s}s';
}
