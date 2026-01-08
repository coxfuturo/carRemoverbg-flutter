import 'dart:io';
import 'dart:typed_data'; // ✅ CORRECT

import 'package:carbgremover/models/BackgroundItem.dart';
import 'package:carbgremover/models/CarImage.dart';
import 'package:carbgremover/screens/CaptureStore.dart';
import 'package:carbgremover/services/ImageExportFromStoreService.dart';
import 'package:carbgremover/services/car_service.dart';
import 'package:carbgremover/utils/ImageBackgroundUtils.dart';
import 'package:carbgremover/utils/Routes.dart';
import 'package:carbgremover/widgets/SliderRow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_compare_slider/image_compare_slider.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  bool _watermarkEnabled = true;
  bool _isApplyingBg = false;
  int _selectedIndex = 0;
  int _currentIndex = 0;
  final int _totalImages = 9;
  double sliderValue = 0.5;
  bool isUploading = false;
  double uploadProgress = 0.0; // 0 → 1


  final List<BackgroundPreset> backgroundPresets = [
    BackgroundPreset(
      title: "Studio",
      imagePath: "assets/backgrounds/studio.jpg",
    ),
    BackgroundPreset(
      title: "Outdoor",
      imagePath: "assets/backgrounds/outdoor.jpg",
    ),
    BackgroundPreset(
      title: "Luxury",
      imagePath: "assets/backgrounds/premium.jpg",
    ),
    BackgroundPreset(
      title: "Premium",
      imagePath: "assets/backgrounds/premium.jpg",
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final store = context.watch<CaptureStore>();

    final images = List<CarImage>.from(store.images)
      ..sort((a, b) => a.poseIndex.compareTo(b.poseIndex));

    final CarImage car = images[_currentIndex];
  }

  Future<void> setBgAll(BackgroundPreset preset) async {
    if (_isApplyingBg) return;
    _isApplyingBg = true;

    final store = context.read<CaptureStore>();

    // 1️⃣ Get all images safely
    final images = List<CarImage>.from(store.images)
      ..sort((a, b) => a.poseIndex.compareTo(b.poseIndex));

    for (final car in images) {
      // 2️⃣ Skip if bgRemoved not ready
      if (car.bgRemoved == null) continue;

      // 3️⃣ Apply background using bytes (NOT File)
      final Uint8List mergedBytes = await ImageBackgroundUtils.applyBackground(
        carPng: car.bgRemoved!, // 👈 transparent PNG bytes
        background: BackgroundItem(
          id: preset.title.toLowerCase(),
          asset: preset.imagePath,
        ),
      );

      // 4️⃣ Save result into model
      store.saveFinalImage(
        car.poseIndex,
        mergedBytes,
        backgroundName: preset.title,
      );
    }

    _isApplyingBg = false;
  }

  Widget _capsuleTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        "Preview  ·  ${_currentIndex + 1} / $_totalImages",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF29B6F6), width: 1.5),
        ),
        child: Icon(icon, color: const Color(0xFF29B6F6), size: 22),
      ),
    );
  }

  Image _safeImage(CarImage car, {required bool isFinal}) {
    if (isFinal && car.finalImage != null) {
      return Image.memory(
        car.finalImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (car.bgRemoved != null) {
      return Image.memory(
        car.bgRemoved!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // fallback → original image
    return Image.file(
      File(car.url),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }


  Future<void> uploadAllImages11() async {
    final store = context.read<CaptureStore>();

    final images = List<CarImage>.from(store.images)
      ..sort((a, b) => a.poseIndex.compareTo(b.poseIndex));

    setState(() => isUploading = true);

    try {
      await CarService.createCarAndUploadAllImages(
        images: images,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => uploadProgress = progress);
        },
      );

      context.read<CaptureStore>().clearAll();
      Fluttertoast.showToast(msg: "Upload completed");

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.dashboard,
            (_) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  Future<void> uploadAllImages() async {
    final store = context.read<CaptureStore>();

    final images = List<CarImage>.from(store.images)
      ..sort((a, b) => a.poseIndex.compareTo(b.poseIndex));

    if (images.isEmpty) {
      Fluttertoast.showToast(msg: "No images to upload");
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0;
    });

    try {
      await CarService.createCarAndUploadAllImages(
        images: images,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => uploadProgress = progress);
        },
      );

      Fluttertoast.showToast(msg: "Upload completed");

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.dashboard,
            (_) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Upload failed");
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    final store = context.watch<CaptureStore>();

    final images = List<CarImage>.from(store.images)
      ..sort((a, b) => a.poseIndex.compareTo(b.poseIndex));

    if (images.isEmpty) {
      return const SizedBox();
    }

    final CarImage car = images[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C2D),
      appBar: AppBar(
        title: _capsuleTitle(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _circleButton(
                  icon: Icons.chevron_left,
                  onTap: () {
                    if (_currentIndex > 0) {
                      setState(() {
                        _currentIndex--;
                        sliderValue = 0.5;
                      });
                    }
                  },
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      "Front ${_currentIndex + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                _circleButton(
                  icon: Icons.chevron_right,
                  onTap: () {
                    if (_currentIndex < images.length - 1) {
                      setState(() {
                        _currentIndex++;
                        sliderValue = 0.5;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              "Before & After",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 220,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ImageCompareSlider(
                  dividerColor: const Color(0xFF29B6F6),
                  itemOne: _safeImage(car, isFinal: false),
                  itemTwo: _safeImage(car, isFinal: true),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text("Background", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),

            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: backgroundPresets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final preset = backgroundPresets[index];
                  final isSelected = index == _selectedIndex;

                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _selectedIndex = index;
                      });

                      await setBgAll(preset);
                    },
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF29B6F6)
                              : Colors.white.withOpacity(0.15),
                          width: isSelected ? 2 : 1,
                        ),
                        image: DecorationImage(
                          image: AssetImage(preset.imagePath), // 👈 IMAGE HERE
                          fit: BoxFit.cover,
                        ),
                      ),

                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            preset.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Color(0xFF0F2A3F),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  const Text(
                    "Adjustments",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// SLIDERS
                  SliderRow(label: "Saturation"),
                  SliderRow(label: "Brightness"),
                  SliderRow(label: "Contrast"),
                  SliderRow(label: "Warmth"),

                  /// DIVIDER (optional but looks clean)
                  Divider(color: Colors.white.withOpacity(0.1), thickness: 1),

                  /// WATERMARK SWITCH
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    // 👈 important for card look
                    value: _watermarkEnabled,
                    onChanged: (value) {
                      setState(() {
                        _watermarkEnabled = value;
                      });
                    },

                    title: const Text(
                      "Watermark",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),

                    activeTrackColor: const Color(0xFF29B6F6),
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade700,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            /// 🔘 BUTTON AREA
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Column(
                children: [
                  /// ALL AS ZIP
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {

                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF29B6F6),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.copy, size: 24, color: Color(0xFF29B6F6)),
                          SizedBox(width: 8),
                          Text(
                            "Apply to All Images",
                            style: TextStyle(
                              color: Color(0xFF29B6F6),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SAVE ALL
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: isUploading
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          value: uploadProgress, // 🔥 REAL PROGRESS
                          minHeight: 6,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF29B6F6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Uploading ${(uploadProgress * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                        : OutlinedButton.icon(
                      onPressed: uploadAllImages,
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFF29B6F6),
                      ),
                      label: const Text(
                        "Upload All Images",
                        style: TextStyle(
                          color: Color(0xFF29B6F6),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF29B6F6),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () async {
                              try {
                                final store = context.read<CaptureStore>();

                                final images = List<CarImage>.from(store.images)
                                  ..sort((a, b) => a.poseIndex.compareTo(b.poseIndex));

                                final CarImage img = images[_currentIndex];

                                final Uint8List? bytes =
                                    img.finalImage ?? img.bgRemoved;

                                if (bytes == null) {
                                  Fluttertoast.showToast(msg: "Image not ready");
                                  return;
                                }

                                final path =
                                await ImageExportFromStoreService.saveSingleImage(
                                  bytes: bytes,
                                  poseIndex: img.poseIndex,
                                );

                                Fluttertoast.showToast(msg: "Saved to Download");
                              } catch (e) {
                                Fluttertoast.showToast(msg: "Download failed");
                              }
                            },

                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF29B6F6),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.file_download_outlined,
                                  size: 24,
                                  color: Color(0xFF29B6F6),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "This Image",
                                  style: TextStyle(
                                    color: Color(0xFF29B6F6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () async {
                              try {
                                final store = context.read<CaptureStore>();
                                final images = List<CarImage>.from(store.images);

                                final path =
                                await ImageExportFromStoreService.saveAsZip(
                                  images,
                                  "car_images",
                                );

                                Fluttertoast.showToast(msg: "ZIP saved to Download");
                              } catch (e) {
                                Fluttertoast.showToast(msg: "ZIP download failed");
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF29B6F6),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.file_download_outlined,
                                  size: 24,
                                  color: Color(0xFF29B6F6),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "All as ZIP",
                                  style: TextStyle(
                                    color: Color(0xFF29B6F6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
