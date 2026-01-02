import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PoseItem extends StatelessWidget {
  final String title;
  final String image;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const PoseItem({
    super.key,
    required this.title,
    required this.selected,
    required this.completed,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;

    if (completed) {
      borderColor = Colors.green; // ✅ completed
    } else if (selected) {
      borderColor = const Color(0xFF29B6F6); // selected
    } else {
      borderColor = Colors.white24;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF0E2235),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: completed || selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                    height: 40,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: completed
                          ? Colors.green
                          : selected
                          ? Colors.white
                          : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            /// ✅ CHECK ICON
            if (completed)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.check_circle, color: Colors.green, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}