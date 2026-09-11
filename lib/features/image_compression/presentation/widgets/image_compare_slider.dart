import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ImageCompareSlider extends StatefulWidget {
  const ImageCompareSlider({
    required this.originalPath,
    required this.compressedPath,
    super.key,
  });

  final String originalPath;
  final String compressedPath;

  @override
  State<ImageCompareSlider> createState() => _ImageCompareSliderState();
}

class _ImageCompareSliderState extends State<ImageCompareSlider> {
  double _splitFraction = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final splitPoint = width * _splitFraction;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _splitFraction += details.delta.dx / width;
              _splitFraction = _splitFraction.clamp(0.0, 1.0);
            });
          },
          child: Stack(
            fit: StackFit.loose,
            alignment: Alignment.center,
            children: [
              // Bottom Image (Compressed)
              Image.file(
                File(widget.compressedPath),
                fit: BoxFit.contain,
              ),

              // Top Image (Original) - Clipped to the left side
              ClipRect(
                clipper: _CompareClipper(splitFraction: _splitFraction),
                child: Image.file(
                  File(widget.originalPath),
                  fit: BoxFit.contain,
                ),
              ),

              // Top Labels
              Positioned(
                top: 16,
                left: 16,
                child: _buildLabel('Original', _splitFraction > 0.2),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: _buildLabel('Compressed', _splitFraction < 0.8),
              ),

              // Draggable Divider Line
              Positioned(
                left: splitPoint - 20, // center the 40px width handle container
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // The Vertical Line
                      Container(
                        width: 2.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 6,
                            )
                          ],
                        ),
                      ),
                      // The Grip
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, bool isVisible) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _CompareClipper extends CustomClipper<Rect> {
  final double splitFraction;
  _CompareClipper({required this.splitFraction});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * splitFraction, size.height);
  }

  @override
  bool shouldReclip(_CompareClipper oldClipper) {
    return splitFraction != oldClipper.splitFraction;
  }
}
