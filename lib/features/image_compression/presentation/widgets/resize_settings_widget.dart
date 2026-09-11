import 'package:flutter/material.dart';

import '../../domain/entities/compression_preset.dart';
import '../controllers/image_compression_controller.dart';

class ResizeSettingsWidget extends StatefulWidget {
  const ResizeSettingsWidget({required this.controller, super.key});

  final ImageCompressionController controller;

  @override
  State<ResizeSettingsWidget> createState() => _ResizeSettingsWidgetState();
}

class _ResizeSettingsWidgetState extends State<ResizeSettingsWidget> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _percentController = TextEditingController();
  final _maxEdgeController = TextEditingController();

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _percentController.dispose();
    _maxEdgeController.dispose();
    super.dispose();
  }

  void _applyMode(ImageResizeMode mode) {
    widget.controller.updateResizeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resizeMode = widget.controller.preset.resizeMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resize Options', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Original'),
              selected: resizeMode.maybeWhen(none: () => true, orElse: () => false),
              onSelected: (val) {
                if (val) _applyMode(const ImageResizeMode.none());
              },
            ),
            ChoiceChip(
              label: const Text('Max Edge'),
              selected: resizeMode.maybeWhen(maxLongEdge: (_) => true, orElse: () => false),
              onSelected: (val) {
                if (val) _applyMode(const ImageResizeMode.maxLongEdge(1920));
              },
            ),
            ChoiceChip(
              label: const Text('Exact Size'),
              selected: resizeMode.maybeWhen(exactSize: (w, h, k) => true, orElse: () => false),
              onSelected: (val) {
                if (val) _applyMode(const ImageResizeMode.exactSize(width: 800, height: 600));
              },
            ),
            ChoiceChip(
              label: const Text('Percentage'),
              selected: resizeMode.maybeWhen(scalePercentage: (_) => true, orElse: () => false),
              onSelected: (val) {
                if (val) _applyMode(const ImageResizeMode.scalePercentage(50));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        resizeMode.when(
          none: () => const SizedBox.shrink(),
          maxLongEdge: (val) {
            _maxEdgeController.text = val.toString();
            return _buildInputRow(
              'Max Edge (px):',
              _maxEdgeController,
              (v) => _applyMode(ImageResizeMode.maxLongEdge(int.tryParse(v) ?? 1920)),
            );
          },
          exactSize: (w, h, keepAspectRatio) {
            _widthController.text = w.toString();
            _heightController.text = h.toString();
            return Column(
              children: [
                _buildInputRow(
                  'Width (px):',
                  _widthController,
                  (v) => _applyMode(ImageResizeMode.exactSize(width: int.tryParse(v) ?? w, height: h, keepAspectRatio: keepAspectRatio)),
                ),
                const SizedBox(height: 8),
                _buildInputRow(
                  'Height (px):',
                  _heightController,
                  (v) => _applyMode(ImageResizeMode.exactSize(width: w, height: int.tryParse(v) ?? h, keepAspectRatio: keepAspectRatio)),
                ),
                CheckboxListTile(
                  title: const Text('Keep Aspect Ratio (Fit inside)'),
                  value: keepAspectRatio,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => _applyMode(ImageResizeMode.exactSize(width: w, height: h, keepAspectRatio: v ?? true)),
                ),
              ],
            );
          },
          scalePercentage: (percentage) {
            _percentController.text = percentage.toStringAsFixed(0);
            return _buildInputRow(
              'Scale (%):',
              _percentController,
              (v) => _applyMode(ImageResizeMode.scalePercentage(double.tryParse(v) ?? 50.0)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
            onSubmitted: onChanged,
            onChanged: (v) {
              // Optionally trigger on every change, but onSubmitted is safer for numbers to avoid errors mid-typing
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.check, size: 20),
          onPressed: () => onChanged(controller.text),
          tooltip: 'Apply',
        ),
      ],
    );
  }
}
