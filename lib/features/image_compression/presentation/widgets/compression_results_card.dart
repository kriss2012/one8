import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/utils/byte_formatter.dart';
import '../../../../core/widgets/section_card.dart';
import '../controllers/image_compression_controller.dart';

class CompressionResultsCard extends StatelessWidget {
  const CompressionResultsCard({required this.controller, super.key});

  final ImageCompressionController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = controller.compressedImages;

    final totalOriginal = controller.totalOriginalBytes;
    final totalCompressed = controller.totalCompressedBytes;
    final totalSaved = totalOriginal - totalCompressed;
    final savedPercentage = controller.savedPercentage;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Batch Compression Results', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            results.isEmpty
                ? 'Compressed output files will appear here with side-by-side metrics.'
                : '${results.length} image${results.length == 1 ? '' : 's'} compressed successfully.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (results.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricStat(
                    label: 'Total Saved',
                    value: totalSaved > 0 ? formatBytes(totalSaved) : '0 B',
                    icon: Icons.savings_rounded,
                  ),
                  _MetricStat(
                    label: 'Reduction',
                    value: '${savedPercentage.toStringAsFixed(1)}%',
                    icon: Icons.trending_down_rounded,
                  ),
                  _MetricStat(
                    label: 'Output Size',
                    value: formatBytes(totalCompressed),
                    icon: Icons.sd_card_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (results.isEmpty)
            const _EmptyState()
          else
            ...results.map(
              (result) => Padding(
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
                          File(result.outputPath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      result.outputFileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${formatBytes(result.originalBytes)} → ${formatBytes(result.compressedBytes)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${result.savedPercentage.toStringAsFixed(0)}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricStat extends StatelessWidget {
  const _MetricStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onPrimaryContainer),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            Icons.tune_rounded,
            size: 36,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Run your first compression batch to view output stats.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
