import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StepItem extends StatelessWidget {
  final String title;
  final int index;
  final int currentStep;

  const StepItem({
    required this.title,
    required this.index,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = index < currentStep;
    final isActive = index == currentStep;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFF1E3F32)
            : isActive
            ? const Color(0xFF163B4D)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? const Color(0xFF4CAF50)
                  : isActive
                  ? const Color(0xFF29B6F6)
                  : Colors.white12,
            ),
            alignment: Alignment.center,
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
              "${index + 1}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDone || isActive ? Colors.white : Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}