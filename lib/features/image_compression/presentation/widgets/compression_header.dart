import 'package:flutter/material.dart';

import '../../../../core/widgets/section_card.dart';

class CompressionHeader extends StatelessWidget {
  const CompressionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Phase 1 · Image Compression',
              style: theme.textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ONE8',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Fast. Private. Local. A high-performance image compression app built for efficiency, complete privacy, and multi-format support.',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
