import 'package:carbgremover/services/service_image_download.dart';
import 'package:carbgremover/utils/app_utils.dart';
import 'package:carbgremover/widgets/photo_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CarDetailScreen extends StatelessWidget {
  final String carId;
  final String heroTag;

  const CarDetailScreen({
    super.key,
    required this.carId,
    required this.heroTag,
  });

  Widget _exportButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: () {
          ImageExportService.showExportOptions(context, carId);
        },
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

  Widget _statusChip(String status) {
    final bool isDone = status.toLowerCase() == "done";

    final Color color = isDone ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF07121E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07121E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _exportButton(context),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => ImageExportService.confirmDelete(context, carId),
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("cars")
            .doc(carId)
            .snapshots(),
        builder: (context, carSnapshot) {
          if (carSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!carSnapshot.hasData || !carSnapshot.data!.exists) {
            return const Center(
              child: Text(
                "Car not found",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final car = carSnapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  (car["carName"] ?? "Unnamed Car").toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                /// DATE + STATUS
                Row(
                  children: [
                    Text(
                      "${AppUtils.formatDate(car["createdAt"])} • ${(car["photos"] ?? 0)} photos",
                      style: const TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(width: 12),
                    _statusChip((car["status"] ?? "In Progress").toString()),
                  ],
                ),

                const SizedBox(height: 20),

                /// PHOTOS GRID
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(uid)
                        .collection("cars")
                        .doc(carId)
                        .collection("images")
                        .orderBy("poseIndex")
                        .snapshots(),
                    builder: (context, imgSnapshot) {
                      if (imgSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!imgSnapshot.hasData ||
                          imgSnapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No images uploaded yet",
                            style: TextStyle(color: Colors.white60),
                          ),
                        );
                      }

                      final images = imgSnapshot.data!.docs;

                      return GridView.builder(
                        itemCount: images.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.85,
                            ),
                        itemBuilder: (context, index) {
                          final img =
                              images[index].data() as Map<String, dynamic>;

                          return PhotoCard(
                            image: img["url"],
                            title: "Photo ${(img["poseIndex"] ?? index) + 1}",
                            subtitle: "Processed",
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
