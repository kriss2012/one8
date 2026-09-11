import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/selected_image.dart';
import '../controllers/image_compression_controller.dart';
import '../widgets/compression_customization_bottom_sheet.dart';
import '../widgets/compression_loader_overlay.dart';
import '../widgets/format_chip_selector.dart';
import '../widgets/hero_stage_workspace.dart';
import '../widgets/image_preview_modal.dart';
import 'compression_results_page.dart';

class ImageCompressionPage extends StatefulWidget {
  const ImageCompressionPage({required this.controller, super.key});

  final ImageCompressionController controller;

  @override
  State<ImageCompressionPage> createState() => _ImageCompressionPageState();
}

class _ImageCompressionPageState extends State<ImageCompressionPage> {
  CompressMediaType _selectedMediaType = CompressMediaType.image;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  void _handleConfigureAndCompress(BuildContext context) {
    if (widget.controller.selectedImages.isEmpty) {
      widget.controller.pickImages();
      return;
    }

    // Launch Stage 2 Customization Bottom Sheet
    CompressionCustomizationBottomSheet.show(
      context,
      widget.controller,
      onStartCompress: () {
        // Trigger Rust/Dart compression engine
        widget.controller.compress();

        // Launch Stage 3 Micro-Animated Loader Overlay
        CompressionLoaderOverlay.show(
          context,
          widget.controller,
          () {
            // Stage 3 completed -> Navigate to Stage 4 Results Screen
            CompressionResultsPage.navigate(context, widget.controller);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasSelectedImages = controller.selectedImages.isNotEmpty;
    final count = controller.selectedImages.length;

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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Compress Studio',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          if (hasSelectedImages)
            IconButton(
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: AppColors.error,
                size: 22,
              ),
              onPressed: controller.clearAll,
              tooltip: 'Clear Selection',
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xs),

            // 1. TOP FORMAT CHIPS STRIP
            FormatChipSelector(
              selectedType: _selectedMediaType,
              onSelectType: (type) {
                setState(() => _selectedMediaType = type);
              },
            ),

            const SizedBox(height: AppSpacing.sm),

            // 2. HERO STAGE WORKSPACE (LOCKED NON-SCROLLABLE 60% VIEWPORT CANVAS)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: HeroStageWorkspace(
                  controller: controller,
                  onPickImages: controller.pickImages,
                  onAddMoreImages: controller.addMoreImages,
                  onTapImageItem: (item) => _handleImageItemTap(context, item),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // 3. DOCKED BOTTOM ACTION COMMANDER (Stage 1 ➔ Launch Stage 2 Bottom Sheet)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _handleConfigureAndCompress(context),
                  icon: HugeIcon(
                    icon: hasSelectedImages
                        ? HugeIcons.strokeRoundedSettings04
                        : HugeIcons.strokeRoundedFolderAdd,
                    color: isDark ? Colors.black : Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    hasSelectedImages
                        ? 'Configure & Compress ($count file${count == 1 ? '' : 's'})'
                        : 'Select Images',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : AppColors.lightTextPrimary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleImageItemTap(BuildContext context, SelectedImage item) {
    ImagePreviewModal.show(context, item, widget.controller);
  }
}
