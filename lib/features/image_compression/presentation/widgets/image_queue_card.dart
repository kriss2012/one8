import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/utils/byte_formatter.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/selected_image.dart';
import '../controllers/image_compression_controller.dart';

class ImageQueueCard extends StatelessWidget {
  const ImageQueueCard({required this.controller, super.key});

  final ImageCompressionController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = controller.selectedImages;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.collections_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Selected Images', style: theme.textTheme.titleLarge),
                ],
              ),
              if (images.isNotEmpty)
                TextButton.icon(
                  onPressed: controller.isCompressing ? null : controller.clearAll,
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            images.isEmpty
                ? 'Select one or more images to preview in the queue.'
                : '${images.length} file${images.length == 1 ? '' : 's'} queued for compression.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (images.isEmpty)
            const _EmptyQueue()
          else
            ...images.map((image) {
              final result = controller.resultFor(image.path);
              final isCompressing = controller.isCompressing;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.file(
                          File(image.path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            image.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _FormatBadge(format: image.format),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: result == null
                          ? Text(
                              formatBytes(image.originalBytes),
                              style: theme.textTheme.bodySmall,
                            )
                          : Row(
                              children: [
                                Text(
                                  '${formatBytes(image.originalBytes)} → ${formatBytes(result.compressedBytes)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '-${result.savedPercentage.toStringAsFixed(0)}%',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    trailing: isCompressing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => controller.removeSelectedImage(image),
                            tooltip: 'Remove',
                          ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.format});

  final SupportedImageFormat format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = format.name.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 44,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'Queue is empty',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Click "Pick Images" above to load JPEG, PNG, or WebP images.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
