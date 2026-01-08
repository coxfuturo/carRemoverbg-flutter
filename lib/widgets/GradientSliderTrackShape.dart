import 'package:flutter/material.dart';

class GradientSliderTrackShape extends SliderTrackShape {
  final LinearGradient gradient;

  const GradientSliderTrackShape({required this.gradient});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 6;
    final trackLeft = offset.dx;
    final trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        Offset? secondaryOffset,
        bool isEnabled = false,
        bool isDiscrete = false,
      }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    final inactiveRect = Rect.fromLTRB(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    // 🎨 Active gradient
    final activePaint = Paint()
      ..shader = gradient.createShader(activeRect)
      ..style = PaintingStyle.fill;

    // 🌑 Inactive track
    final inactivePaint = Paint()
      ..color =  Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, const Radius.circular(8)),
      activePaint,
    );

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(inactiveRect, const Radius.circular(8)),
      inactivePaint,
    );
  }
}

