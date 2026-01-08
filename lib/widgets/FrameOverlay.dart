import 'package:carbgremover/widgets/Corner.dart';
import 'package:flutter/cupertino.dart';

class FrameOverlay extends StatelessWidget {
  final double width;
  final double height;
  final double cornerSize;

  const FrameOverlay({
    super.key,
    this.width = 500,
    this.height = 300,
    this.cornerSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Corner(alignment: Alignment.topLeft, size: cornerSize),
          Corner(alignment: Alignment.topRight, size: cornerSize),
          Corner(alignment: Alignment.bottomLeft, size: cornerSize),
          Corner(alignment: Alignment.bottomRight, size: cornerSize),
        ],
      ),
    );
  }
}
