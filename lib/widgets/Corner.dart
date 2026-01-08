import 'package:carbgremover/widgets/corner_painter.dart';
import 'package:flutter/cupertino.dart';

class Corner extends StatelessWidget {
  final Alignment alignment;
  final double size;

  const Corner({
    required this.alignment,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: CornerPainter(alignment),
        ),
      ),
    );
  }
}
