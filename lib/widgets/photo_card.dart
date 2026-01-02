import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const PhotoCard({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 160,
            color: Colors.white,
            child: Image.network(
              image,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image,
                color: Colors.white38,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}