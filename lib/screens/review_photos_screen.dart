import 'dart:io';

import 'package:camera/camera.dart';
import 'package:carbgremover/models/CarImage.dart';
import 'package:carbgremover/models/CarPose.dart';
import 'package:carbgremover/screens/CaptureStore.dart';
import 'package:carbgremover/utils/Routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ReviewPhotosScreen extends StatefulWidget {
  const ReviewPhotosScreen({super.key});

  @override
  State<ReviewPhotosScreen> createState() => _ReviewPhotosScreenState();
}

class _ReviewPhotosScreenState extends State<ReviewPhotosScreen> {
  int get totalPoses => poses.length;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }


  @override
  Widget build(BuildContext context) {


    final store = context.watch<CaptureStore>();
    final int capturedCount = store.capturedCount;


    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF07121E),
        appBar: AppBar(
          title: _progressChip(capturedCount),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white, // 👈 back button color
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              /// 🔝 HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    const Text(
                      "Review Your Photos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Check each angle before enhancement",
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ),

              /// 📷 GRID
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: totalPoses,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final CarImage? car = store.getByPoseIndex(index);

                      return car != null
                          ? _capturedCard(
                        context,
                        index,
                        car,
                        onRetake: () {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
                          Navigator.pop(context, {
                            "action": "retake",
                            "poseIndex": index,
                          });
                        },
                      )
                          : _emptyCard(index);
                    },
                  ),
                ),
              ),

              /// 🔘 ACTION BUTTONS
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.enhanceImagescreen);
                        },

                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(MaterialState.disabled)) {
                              return const Color(0xFF29B6F6);
                            }
                            return const Color(0xFF29B6F6);
                          }),

                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        child: Text(
                          "✨ Enhance All $capturedCount Photos",
                          // ✅ dynamic text
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// CONTINUE CAPTURING
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF29B6F6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Continue Capturing",
                          style: TextStyle(
                            color: Color(0xFF29B6F6),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${totalPoses - capturedCount} more angles remaining",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔵 PROGRESS CHIP
  Widget _progressChip(int capturedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2235),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        "$capturedCount of $totalPoses captured",
        style: const TextStyle(
          color: Color(0xFF29B6F6),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// ✅ CAPTURED CARD (RET AKE UI)
  Widget _capturedCard(
      BuildContext context,
      int index,
      CarImage car, {
        required VoidCallback onRetake,
      }) {
    final ImageProvider imageProvider =
    car.finalImage != null
        ? MemoryImage(car.finalImage!)
        : car.bgRemoved != null
        ? MemoryImage(car.bgRemoved!)
        : FileImage(File(car.url));

    return GestureDetector(
      onTap: onRetake,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E2235),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  /// RETAKE OVERLAY
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.18),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const Positioned.fill(
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0x99000000),
                          borderRadius:
                          BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Retake",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: const Color(0xFF07121E),
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      poses[index].name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📸 EMPTY CARD
  Widget _emptyCard(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white38,
              size: 28,
            ),

            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                poses[index].name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
