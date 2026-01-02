import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CornerPainter extends CustomPainter {
  final Alignment alignment;

  CornerPainter(this.alignment);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final double w = size.width;
    final double h = size.height;

    if (alignment == Alignment.topLeft) {
      // ┌
      canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
      canvas.drawLine(Offset(0, 0), Offset(0, h), paint);
    } else if (alignment == Alignment.topRight) {
      // ┐
      canvas.drawLine(Offset(w, 0), Offset(0, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
    } else if (alignment == Alignment.bottomLeft) {
      // └
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
      canvas.drawLine(Offset(0, h), Offset(0, 0), paint);
    } else if (alignment == Alignment.bottomRight) {
      // ┘
      canvas.drawLine(Offset(w, h), Offset(0, h), paint);
      canvas.drawLine(Offset(w, h), Offset(w, 0), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}