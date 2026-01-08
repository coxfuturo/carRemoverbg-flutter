// widgets/angle_card.dart
import 'package:flutter/material.dart';

class AngleCard extends StatelessWidget {
  final int index;
  final String label;
  final bool captured;
  final VoidCallback? onTap;

  const AngleCard({
    super.key,
    required this.index,
    required this.label,
    required this.captured,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: captured ? Colors.green : Colors.white24,
            style: captured ? BorderStyle.solid : BorderStyle.solid,
          ),
          color: const Color(0xFF0E2235),
        ),
        child: Center(
          child: captured
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(height: 6),
                    Text(label),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, color: Colors.white38),
                    const SizedBox(height: 6),
                    Text(label, style: const TextStyle(color: Colors.white38)),
                  ],
                ),
        ),
      ),
    );
  }
}
