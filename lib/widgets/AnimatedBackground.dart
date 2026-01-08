import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground();

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: [
            Positioned(
              top: 120,
              left: -80,
              child: _glow(Colors.cyan, 220),
            ),
            Positioned(
              bottom: 80,
              right: -60,
              child: _glow(Colors.blue, 200),
            ),
          ],
        );
      },
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 140,
          ),
        ],
      ),
    );
  }
}
