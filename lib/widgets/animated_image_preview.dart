import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:carbgremover/models/CarImage.dart';

class AnimatedImagePreview extends StatelessWidget {
  final CarImage img;

  const AnimatedImagePreview({
    super.key,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    final Uint8List? imageToShow = img.finalImage ?? img.bgRemoved;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0)
                .animate(animation),
            child: child,
          ),
        );
      },
      child: imageToShow != null
      // ✅ SHOW PROCESSED IMAGE (MEMORY)
          ? Image.memory(
        imageToShow,
        key: ValueKey(
          "${img.background}_${imageToShow.length}",
        ),
        fit: BoxFit.contain,
      )
      // ✅ FALLBACK → SHOW ORIGINAL FROM FIREBASE URL
          : Image.network(
        img.url,
        key: const ValueKey("original_url"),
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, size: 40),
      ),
    );
  }
}
