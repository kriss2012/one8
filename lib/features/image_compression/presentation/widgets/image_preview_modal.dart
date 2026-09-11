import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import 'image_compare_slider.dart';
import '../../domain/entities/compression_preset.dart';
import '../../domain/entities/selected_image.dart';
import '../controllers/image_compression_controller.dart';

class ImagePreviewModal extends StatefulWidget {
  const ImagePreviewModal({
    required this.item,
    required this.controller,
    super.key,
  });

  final SelectedImage item;
  final ImageCompressionController controller;

  static Future<void> show(
    BuildContext context,
    SelectedImage item,
    ImageCompressionController controller,
  ) {
    return showGeneralDialog(
      context: context,
      barrierColor: Theme.of(context).scaffoldBackgroundColor,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Preview',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: ImagePreviewModal(item: item, controller: controller),
        );
      },
    );
  }

  @override
  State<ImagePreviewModal> createState() => _ImagePreviewModalState();
}

class _ImagePreviewModalState extends State<ImagePreviewModal> {
  late CompressionPreset _localPreset;

  @override
  void initState() {
    super.initState();
    _localPreset = widget.controller.preset;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // We listen to the controller so that if the compression finishes while the modal is open, it updates.
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final compressedResult = widget.controller.resultFor(widget.item.path);
        final isCompressed = compressedResult != null;
        
        final displayPath = widget.item.path;
            
        final origMb = (widget.item.originalBytes / (1024 * 1024)).toStringAsFixed(2);
        final compMb = isCompressed ? (compressedResult.compressedBytes / (1024 * 1024)).toStringAsFixed(2) : null;
        final savings = isCompressed ? compressedResult.savedPercentage.toStringAsFixed(1) : null;

        return Material(
          color: theme.scaffoldBackgroundColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 2. Modal Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xl),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.fileName,
                                  style: AppTypography.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                                      ),
                                      child: Text(
                                        widget.item.format.badgeName,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isCompressed ? 'Processed' : 'Pending Compression',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Image Display Area (Interactive Viewer or Slider)
                      Expanded(
                        child: Center(
                          child: Hero(
                            tag: 'image_preview_${widget.item.path}',
                            child: GlassCard(
                              padding: EdgeInsets.zero,
                              opacity: 0.05,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: isCompressed 
                                  ? ImageCompareSlider(
                                      originalPath: widget.item.path,
                                      compressedPath: compressedResult.outputPath,
                                    )
                                  : InteractiveViewer(
                                      minScale: 1.0,
                                      maxScale: 4.0,
                                      child: Image.file(
                                        File(displayPath),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ).animate().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Compact Controls (Stats + Settings + Actions)
                      GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        opacity: 0.08,
                        child: Column(
                          children: [
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatColumn('Original', '$origMb MB', isDark),
                                if (isCompressed) ...[
                                  Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
                                  _buildStatColumn('Compressed', '$compMb MB', isDark, highlight: true),
                                  Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
                                  _buildStatColumn('Saved', '$savings%', isDark, highlight: true, highlightColor: AppColors.primary),
                                ] else ...[
                                  Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
                                  _buildStatColumn('Status', 'Pending', isDark),
                                ],
                              ],
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: Colors.white10, height: 1),
                            ),

                            // Quality Control
                            Row(
                              children: [
                                Text(
                                  'Quality',
                                  style: AppTypography.textTheme.labelMedium?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: AppColors.primary,
                                      inactiveTrackColor: Colors.white10,
                                      thumbColor: AppColors.primary,
                                      overlayColor: AppColors.primary.withValues(alpha: 0.2),
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                    ),
                                    child: Slider(
                                      value: _localPreset.quality.toDouble().clamp(1.0, 100.0),
                                      min: 1,
                                      max: 100,
                                      divisions: 99,
                                      onChanged: (value) {
                                        setState(() {
                                          _localPreset = _localPreset.copyWith(
                                            quality: value.round(),
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${_localPreset.quality}%',
                                  style: AppTypography.textTheme.labelMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      widget.controller.removeSelectedImage(widget.item);
                                      Navigator.of(context).pop();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Remove'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: widget.controller.isCompressing ? null : () {
                                      widget.controller.compressSingleImage(widget.item, _localPreset);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedZap, color: Colors.black, size: 16),
                                    label: Text(
                                      isCompressed ? 'Re-compress' : 'Compress Now', 
                                      style: const TextStyle(fontWeight: FontWeight.w700)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatColumn(String label, String value, bool isDark, {bool highlight = false, Color? highlightColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: highlight ? (highlightColor ?? Colors.white) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
