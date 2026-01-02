import 'package:carbgremover/screens/CarViewDetailScreen.dart';
import 'package:flutter/material.dart';

class HomeCarCard extends StatelessWidget {
  final String carId;
  final String? image;
  final String title;
  final String date;
  final int photos;
  final String status;
  final Color statusColor;

  const HomeCarCard({
    super.key,
    required this.carId,
    required this.image,
    required this.title,
    required this.date,
    required this.photos,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2235),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          /// 🔥 HERO IMAGE
          Hero(
            tag: "car-image-$carId",
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 72,
                height: 72,
                color: const Color(0xFF122B45),
                child: image != null
                    ? Image(
                        image: image!.startsWith("http")
                            ? NetworkImage(image!)
                            : AssetImage(image!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, color: Colors.white38),
                      )
                    : const Icon(Icons.image, color: Colors.white38),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Text(
                  "$date • $photos photos",
                  style: const TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 10),

                /// BUTTONS
                Row(
                  children: [
                    _actionButton(context, Icons.remove_red_eye, "View"),
                    const SizedBox(width: 10),
                    _actionButton(context, Icons.download, "Export"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String text) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarDetailScreen(
              carId: carId, // ✅ CORRECT
              heroTag: "car-image-$carId", // 🔥 PASS HERO TAG
            ),
          ),
        );
      },
      icon: Icon(icon, size: 16, color: const Color(0xFF29B6F6)),
      label: Text(text, style: const TextStyle(color: Color(0xFF29B6F6))),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF29B6F6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
