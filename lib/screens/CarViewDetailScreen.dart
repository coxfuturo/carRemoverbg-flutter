import 'package:carbgremover/services/service_image_download.dart';
import 'package:carbgremover/services/car_service.dart';
import 'package:carbgremover/utils/Routes.dart';
import 'package:carbgremover/utils/app_utils.dart';
import 'package:carbgremover/utils/permissions.dart';
import 'package:carbgremover/widgets/photo_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CarDetailScreen extends StatelessWidget {
  final String carId;
  final String heroTag;

  const CarDetailScreen({
    super.key,
    required this.carId,
    required this.heroTag,
  });

  Future<void> exportImagesAsZip(BuildContext context) async {
    try {
      final granted = await requestStoragePermission();
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      final zipPath = await ImageExportService.exportAsZip(carId);

      if (!context.mounted) return;

      await Share.shareXFiles([XFile(zipPath)], text: "Car images export");
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Export failed")));
    }
  }

  Future<void> downloadImagesIndividually(BuildContext context) async {
    try {
      final granted = await requestStoragePermission();
      if (!granted) return;

      await ImageExportService.downloadImages(carId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Images saved to Downloads")),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Download failed")));
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(

      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0E2235),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Delete Session",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Are you sure you want to delete this car session?\n\nThis action cannot be undone.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      Navigator.pop(context, true);
      await CarService.deleteCar(carId);
    }
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E2235),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.archive, color: Colors.white),
                title: const Text(
                  "Download as ZIP",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  exportImagesAsZip(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.white),
                title: const Text(
                  "Download images",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  downloadImagesIndividually(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text(
                  "Share images",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  exportImagesAsZip(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _exportButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: () {
          _showExportOptions(context);
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
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.cameraCaptureScreen,
                arguments: {
                  "carId": carId,
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _confirmDelete(context),
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
                        return const Center(
                            child: CircularProgressIndicator());
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
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          final img =
                          images[index].data() as Map<String, dynamic>;

                          return PhotoCard(
                            image: img["url"],
                            title:
                            "Photo ${(img["poseIndex"] ?? index) + 1}",
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
