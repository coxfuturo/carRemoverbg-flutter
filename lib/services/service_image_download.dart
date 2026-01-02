import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ImageExportService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static const _downloadDir = "/storage/emulated/0/Download";

  /// Export images as ZIP → returns zip file path
  static Future<String> exportAsZip(String carId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _firestore
        .collection("users")
        .doc(uid)
        .collection("cars")
        .doc(carId)
        .collection("images")
        .orderBy("index")
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception("No images found");
    }

    final archive = Archive();
    int i = 1;

    for (final doc in snapshot.docs) {
      final url = doc["url"];
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        archive.addFile(
          ArchiveFile(
            "image_$i.png",
            res.bodyBytes.length,
            res.bodyBytes,
          ),
        );
        i++;
      }
    }

    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception("ZIP creation failed");
    }

    final zipFile = File("$_downloadDir/car_$carId.zip");
    await zipFile.writeAsBytes(zipData);

    return zipFile.path;
  }

  /// Download images individually
  static Future<void> downloadImages(String carId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _firestore
        .collection("users")
        .doc(uid)
        .collection("cars")
        .doc(carId)
        .collection("images")
        .orderBy("index")
        .get();

    int i = 1;
    for (final doc in snapshot.docs) {
      final res = await http.get(Uri.parse(doc["url"]));
      await File("$_downloadDir/image_$i.png").writeAsBytes(res.bodyBytes);
      i++;
    }
  }
}
