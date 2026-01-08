import 'dart:io';
import 'package:archive/archive.dart';
import 'package:carbgremover/services/car_service.dart';
import 'package:carbgremover/utils/permissions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class ImageExportService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static const _downloadDir = "/storage/emulated/0/Download";


  static Future<void> confirmDelete(BuildContext context, String carId) async {
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



  /// ===========================
  /// EXPORT OPTIONS BOTTOM SHEET
  /// ===========================
  static Future<void> showExportOptions(
      BuildContext context, String carId) async {
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
                  exportImagesAsZip(context, carId);
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
                  downloadImagesIndividually(context, carId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text(
                  "Share images",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  shareImagesAsZip(context, carId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// ===========================
  /// DOWNLOAD INDIVIDUAL IMAGES
  /// ===========================
  static Future<void> downloadImagesIndividually(
      BuildContext context, String carId) async {
    try {
      final granted = await requestStoragePermission();
      if (!granted) return;

      await downloadImages(carId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Images saved to Downloads")),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download failed")),
      );
    }
  }

  /// ===========================
  /// EXPORT AS ZIP & SHARE
  /// ===========================
  static Future<void> exportImagesAsZip(
      BuildContext context, String carId) async {
    try {
      final granted = await requestStoragePermission();
      if (!granted) return;

      final zipPath = await exportAsZip(carId);

      if (!context.mounted) return;
      await Share.shareXFiles(
        [XFile(zipPath)],
        text: "Car images export",
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Export failed")),
      );
    }
  }

  static Future<void> shareImagesAsZip(
      BuildContext context, String carId) async {
    await exportImagesAsZip(context, carId);
  }

  /// ===========================
  /// CORE ZIP CREATION
  /// ===========================
  static Future<String> exportAsZip(String carId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _firestore
        .collection("users")
        .doc(uid)
        .collection("cars")
        .doc(carId)
        .collection("images")
        .orderBy("poseIndex")
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception("No images found");
    }

    final archive = Archive();

    for (final doc in snapshot.docs) {
      final url = doc["url"];
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        archive.addFile(
          ArchiveFile(
            "pose_${doc["poseIndex"]}.png",
            response.bodyBytes.length,
            response.bodyBytes,
          ),
        );
      }
    }

    final zipData = ZipEncoder().encode(archive)!;
    final zipFile = File("$_downloadDir/car_$carId.zip");

    await zipFile.writeAsBytes(zipData, flush: true);
    return zipFile.path;
  }

  /// ===========================
  /// DOWNLOAD INDIVIDUAL FILES
  /// ===========================
  static Future<void> downloadImages(String carId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _firestore
        .collection("users")
        .doc(uid)
        .collection("cars")
        .doc(carId)
        .collection("images")
        .orderBy("poseIndex")
        .get();

    for (final doc in snapshot.docs) {
      final response = await http.get(Uri.parse(doc["url"]));
      if (response.statusCode != 200) continue;

      final file = File(
        "$_downloadDir/pose_${doc["poseIndex"]}.png",
      );

      await file.writeAsBytes(response.bodyBytes, flush: true);
    }
  }
}
