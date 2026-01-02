import 'dart:io';

import 'package:carbgremover/models/BackgroundItem.dart';
import 'package:carbgremover/models/CarImage.dart';
import 'package:carbgremover/services/RemoveBgService.dart';
import 'package:carbgremover/services/car_service.dart';
import 'package:carbgremover/utils/ImageBackgroundUtils.dart';
import 'package:carbgremover/utils/Routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PreviewScreen extends StatefulWidget {
  final String carId;

  const PreviewScreen({super.key, required this.carId});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  List<CarImage> carImages = [];
  int selectedIndex = 0;

  bool isProcessing = false;
  bool isUploading = false;

  final List<BackgroundItem> backgrounds = [
    BackgroundItem(id: "transparent", asset: "assets/images/frame1.jpg"),
    BackgroundItem(id: "studio_white", asset: "assets/images/frame2.jpg"),
    BackgroundItem(id: "dark_studio", asset: "assets/images/frame3.jpg"),
    BackgroundItem(id: "outdoor", asset: "assets/images/frame1.jpg"),
  ];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  // --------------------------------------------------
  // LOAD IMAGES
  // --------------------------------------------------
  Future<void> _loadImages() async {
    final images = await CarService.fetchCarImages(widget.carId);
    if (mounted) {
      setState(() => carImages = images);
    }
  }

  // --------------------------------------------------
  // DOWNLOAD IMAGE
  // --------------------------------------------------
  Future<Uint8List> _downloadImage(String url) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    return consolidateHttpClientResponseBytes(response);
  }

  // --------------------------------------------------
  // PREVIEW BUILDER (SAFE)
  // --------------------------------------------------
  Widget _buildPreview(CarImage img) {
    if (img.finalImage != null) {
      return Image.memory(img.finalImage!, fit: BoxFit.contain);
    }

    if (img.bgRemoved != null) {
      return Image.memory(img.bgRemoved!, fit: BoxFit.contain);
    }

    return Image.network(
      img.url,
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
    );
  }

  // --------------------------------------------------
  // REMOVE BG SINGLE
  // --------------------------------------------------
  Future<void> removeBgSingle() async {
    if (isProcessing) return;

    setState(() => isProcessing = true);
    try {
      final img = carImages[selectedIndex];
      final bytes = await _downloadImage(img.url);
      img.bgRemoved = await RemoveBgService.removeBackgroundFromBytes(bytes);
    } catch (_) {
      Fluttertoast.showToast(msg: "Failed to remove background");
    }
    setState(() => isProcessing = false);
  }

  // --------------------------------------------------
  // REMOVE BG ALL
  // --------------------------------------------------
  Future<void> removeBgAll() async {
    if (isProcessing) return;

    setState(() => isProcessing = true);
    try {
      for (final img in carImages) {
        if (img.bgRemoved == null) {
          final bytes = await _downloadImage(img.url);
          img.bgRemoved = await RemoveBgService.removeBackgroundFromBytes(
            bytes,
          );
        }
      }
    } catch (_) {
      Fluttertoast.showToast(msg: "Failed to process images");
    }
    setState(() => isProcessing = false);
  }

  // --------------------------------------------------
  // APPLY BG SINGLE
  // --------------------------------------------------
  Future<void> setBgSingle(BackgroundItem bg) async {
    final img = carImages[selectedIndex];

    if (img.bgRemoved == null) {
      Fluttertoast.showToast(msg: "Remove background first");
      return;
    }

    setState(() => isProcessing = true);
    img.finalImage = await ImageBackgroundUtils.applyBackground(
      carPng: img.bgRemoved!,
      background: bg,
    );
    img.background = bg.id;
    setState(() => isProcessing = false);
  }

  // --------------------------------------------------
  // APPLY BG ALL
  // --------------------------------------------------
  Future<void> setBgAll(String bgId) async {
    final bg = backgrounds.firstWhere((b) => b.id == bgId);

    setState(() => isProcessing = true);
    for (final img in carImages) {
      if (img.bgRemoved != null) {
        img.finalImage = await ImageBackgroundUtils.applyBackground(
          carPng: img.bgRemoved!,
          background: bg,
        );
        img.background = bg.id;
      }
    }
    setState(() => isProcessing = false);
  }

  // --------------------------------------------------
  // SAVE IMAGE
  // --------------------------------------------------
  Future<void> saveCurrentImage() async {
    final img = carImages[selectedIndex];
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // ❗ Ensure BG removed
    if (img.bgRemoved == null) {
      Fluttertoast.showToast(msg: "Remove background first");
      return;
    }

    setState(() => isUploading = true);

    try {
      // 🔹 Upload transparent PNG
      final ref = FirebaseStorage.instance.ref(
        "users/$uid/cars/${widget.carId}/pose_${img.poseIndex}.png",
      );

      await ref.putData(img.bgRemoved!);
      final url = await ref.getDownloadURL();

      final userRef =
      FirebaseFirestore.instance.collection("users").doc(uid);

      // 🔹 Update image document
      await userRef
          .collection("cars")
          .doc(widget.carId)
          .collection("images")
          .doc(img.imageDocId)
          .update({
        "url": url,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      // 🔹 UPDATE CAR STATUS → DONE
      await userRef
          .collection("cars")
          .doc(widget.carId)
          .update({
        "status": "Done",
        "updatedAt": FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(msg: "Image saved successfully");

      // 🔹 Navigate after everything finishes
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.dashboard,
            (route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to save image");
    }

    if (mounted) {
      setState(() => isUploading = false);
    }
  }



  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (carImages.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF07121E),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07121E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07121E),
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 back button color
        ),
        title: const Text(
          "Preview",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // PREVIEW
            Expanded(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                child: isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : _buildPreview(carImages[selectedIndex]),
              ),
            ),

            // CONTROLS
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // THUMBNAILS
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: carImages.length,
                        itemBuilder: (_, index) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedIndex = index),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedIndex == index
                                      ? Colors.blue
                                      : Colors.white24,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.network(
                                carImages[index].url,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ACTIONS
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: removeBgSingle,
                              child: const Text("Remove BG"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: removeBgAll,
                              child: const Text("Remove BG All"),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BACKGROUNDS
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: backgrounds.length,
                        itemBuilder: (_, index) {
                          final bg = backgrounds[index];
                          return GestureDetector(
                            onTap: () => setBgSingle(bg),
                            onLongPress: () => setBgAll(bg.id),
                            child: Container(
                              width: 90,
                              margin: const EdgeInsets.all(8),
                              child: Image.asset(bg.asset, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ),

                    // SAVE
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isUploading ? null : saveCurrentImage,
                          child: isUploading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text("Save Image"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
