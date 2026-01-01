import 'package:flutter/material.dart';

class CarDetailScreen extends StatelessWidget {
  const CarDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121E),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF07121E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _exportButton(),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            const Text(
              "BMW 8 Series",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            /// DATE + STATUS
            Row(
              children: [
                const Text(
                  "2025-10-15 • 2 photos",
                  style: TextStyle(color: Colors.white60),
                ),
                const SizedBox(width: 12),
                _statusChip("Processed"),
              ],
            ),

            const SizedBox(height: 20),

            /// PHOTOS GRID
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: const [
                  _PhotoCard(
                    image: "assets/images/car1.jpg",
                    title: "Front",
                    subtitle: "Studio White",
                  ),
                  _PhotoCard(
                    image: "assets/images/car1.jpg",
                    title: "3/4 Front Left",
                    subtitle: "Studio White",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// EXPORT BUTTON
  Widget _exportButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download, size: 18),
        label: const Text("Export"),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF29B6F6),
          side: const BorderSide(color: Color(0xFF29B6F6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  /// STATUS CHIP
  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _PhotoCard({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// IMAGE
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 8),

        /// TITLE
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 2),

        /// SUBTITLE
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

