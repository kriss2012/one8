import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/action_tile.dart';
import '../../../../core/widgets/section_card.dart';
import '../controllers/image_compression_controller.dart';

class CompressionActions extends StatelessWidget {
  const CompressionActions({required this.controller, super.key});

  final ImageCompressionController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          ActionTile(
            title: 'Select Images',
            subtitle: 'Pick photos from gallery',
            icon: HugeIcons.strokeRoundedImageAdd01,
            iconColor: AppColors.info,
            onTap: controller.pickImages,
            showDivider: true,
          ),
          ActionTile(
            title: 'Compress Batch',
            subtitle: 'Start compression process',
            icon: HugeIcons.strokeRoundedArchive01,
            iconColor: AppColors.warning,
            onTap: controller.selectedImages.isEmpty || controller.isCompressing
                ? null
                : controller.compress,
            showDivider: true,
          ),
          ActionTile(
            title: 'Save Outputs',
            subtitle: 'Download compressed files',
            icon: HugeIcons.strokeRoundedDownload01,
            iconColor: AppColors.success,
            onTap: controller.compressedImages.isEmpty
                ? null
                : controller.saveCompressedImages,
            showDivider: true,
          ),
          ActionTile(
            title: 'Share Files',
            subtitle: 'Send compressed images',
            icon: HugeIcons.strokeRoundedShare01,
            iconColor: AppColors.primary,
            onTap: controller.compressedImages.isEmpty
                ? null
                : controller.shareCompressedImages,
            showDivider: false, // Last item has no divider
          ),
        ],
      ),
    );
  }
}
