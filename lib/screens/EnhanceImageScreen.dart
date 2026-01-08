import 'dart:async';
import 'dart:io';
import 'dart:typed_data'; // ✅ CORRECT

import 'package:carbgremover/models/CarImage.dart';
import 'package:carbgremover/models/ProcessingStep.dart';
import 'package:carbgremover/screens/CaptureStore.dart';
import 'package:carbgremover/services/RemoveBgService.dart';
import 'package:carbgremover/utils/Routes.dart';
import 'package:carbgremover/widgets/AnimatedBackground.dart';
import 'package:carbgremover/widgets/PulseRing.dart';
import 'package:carbgremover/widgets/StepItem.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

class EnhanceImageScreen extends StatefulWidget {
  const EnhanceImageScreen({super.key});

  @override
  State<EnhanceImageScreen> createState() => _EnhanceImageScreenState();
}

class _EnhanceImageScreenState extends State<EnhanceImageScreen> {
  // ================= STATE =================
  int currentStep = 0;
  double progress = 0;
  int processingIndex = -1;
  final Set<int> completedIndexes = {};
  bool _fakeLoaderRunning = false;
  double overallProgress = 0.0;
  bool _overallFakeRunning = false;


// ================= ENTRY POINT =================
  Future<void> startProcessingFlow() async {
    final store = context.read<CaptureStore>();

    final images = List<CarImage>.from(store.images)
      ..sort((a, b) => a.poseIndex.compareTo(b.poseIndex));

    completedIndexes.clear();
    progress = 0;
    overallProgress = 0;

    _fakeLoaderRunning = true;

    // 🔄 START FAKE UI
    _startFakeLoader(images);
    _startOverallFakeProgress();

    // ⚙️ REAL PROCESSING
    await _processAllImagesInBackground();

    // 🛑 STOP FAKE UI
    _fakeLoaderRunning = false;
    _stopOverallFakeProgress();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, Routes.editorScreen);
  }

  // ================= FAKE LOADER =================
// Infinite UI-only loader (NO API dependency)
// Rotates steps, progress, and thumbnails smoothly
  void _startFakeLoader(List<CarImage> images) async {
    int step = 0;
    int imgIndex = 0;

    while (_fakeLoaderRunning && mounted) {
      setState(() {
        // rotate which thumbnail looks "processing"
        processingIndex = images.isNotEmpty
            ? images[imgIndex].poseIndex
            : -1;

        // loop steps 0..4
        currentStep = step % 5;

        // smooth fake progress (never reaches 100 by itself)
        progress += 3;
        if (progress >= 95) progress = 20;
      });

      step++;
      if (images.isNotEmpty) {
        imgIndex = (imgIndex + 1) % images.length;
      }

      await Future.delayed(const Duration(milliseconds: 120));
    }
  }


  void _startOverallFakeProgress() async {
    _overallFakeRunning = true;

    while (_overallFakeRunning && mounted) {
      setState(() {
        overallProgress += 0.004;

        if (overallProgress >= 0.95) {
          overallProgress = 0.95; // never reach 100% until real work done
        }
      });

      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  void _stopOverallFakeProgress() {
    _overallFakeRunning = false;
    setState(() {
      overallProgress = 1.0; // jump to 100% at end
    });
  }


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startProcessingFlow();
    });
  }



// ================= REAL BACKGROUND PROCESS =================
  Future<void> _processAllImagesInBackground() async {
    final store = context.read<CaptureStore>();

    final images = List<CarImage>.from(store.images)
      ..sort((a, b) => a.poseIndex.compareTo(b.poseIndex));

    for (final car in images) {
      if (!mounted) return;

      final Uint8List bgRemovedBytes =
      await enhanceAndRemoveBg(File(car.url));

      store.saveNoBgImage(car.poseIndex, bgRemovedBytes);

      setState(() {
        completedIndexes.add(car.poseIndex);
      });
    }
  }

// ================= IMAGE PIPELINE =================
  Future<Uint8List> enhanceAndRemoveBg(File input) async {
    final File enhancedFile = await enhanceImageLocally(input);

    final Uint8List bgRemovedBytes =
    await RemoveBgService.removeBackground(enhancedFile);

    return bgRemovedBytes;
  }

// ================= LOCAL ENHANCEMENT =================
  Future<File> enhanceImageLocally(File input) async {
    final bytes = await input.readAsBytes();
    img.Image original = img.decodeImage(bytes)!;

    img.Image enhanced = img.adjustColor(
      original,
      contrast: 1.25,
      brightness: 1.05,
      saturation: 1.18,
    );

    enhanced = _localContrast(enhanced);

    enhanced = img.convolution(
      enhanced,
      filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
    );

    enhanced = img.convolution(
      enhanced,
      filter: [1, 2, 1, 2, 4, 2, 1, 2, 1],
      div: 16,
    );

    final outputFile = File(
      input.path.replaceFirst(RegExp(r'\.(jpg|jpeg|png)$'), '_enhanced.png'),
    );

    await outputFile.writeAsBytes(img.encodePng(enhanced));
    return outputFile;
  }

// ================= LOCAL CONTRAST =================
  img.Image _localContrast(img.Image image) {
    final out = img.Image(width: image.width, height: image.height);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final a = pixel.a.toInt();

        final lum = 0.299 * r + 0.587 * g + 0.114 * b;
        const factor = 1.15;

        final nr = (lum + (r - lum) * factor).clamp(0, 255).toInt();
        final ng = (lum + (g - lum) * factor).clamp(0, 255).toInt();
        final nb = (lum + (b - lum) * factor).clamp(0, 255).toInt();

        out.setPixelRgba(x, y, nr, ng, nb, a);
      }
    }
    return out;
  }


  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B2A3D), Color(0xFF061A28)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const AnimatedBackground(),

              Column(
                children: [
                  const SizedBox(height: 12),

                  /// TOP THUMBNAILS
                  _topThumbnails(),

                  const SizedBox(height: 36),

                  /// 🔥 SCROLLABLE CONTENT (FIXES OVERFLOW)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _pulseIcon(),

                          const SizedBox(height: 24),

                          const Text(
                            "Enhancing Front",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "AI is working its magic...",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 28),

                          _progressBar(),

                          const SizedBox(height: 24),

                          _stepsList(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  /// FIXED BOTTOM BUTTON
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF29B6F6),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFF29B6F6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- COMPONENTS ----------------
  Widget _topThumbnails() {
    return SizedBox(
      height: 72,
      child: Consumer<CaptureStore>(
        builder: (context, store, _) {
          final images = List<CarImage>.from(store.images)
            ..sort((a, b) => a.poseIndex.compareTo(b.poseIndex));

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: images.length,
            // ✅ NO +1
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final car = images[index];

              final ImageProvider image = car.finalImage != null
                  ? MemoryImage(car.finalImage!)
                  : car.bgRemoved != null
                  ? MemoryImage(car.bgRemoved!)
                  : FileImage(File(car.url));

              final bool isProcessing = car.poseIndex == processingIndex;

              final bool isCompleted = completedIndexes.contains(car.poseIndex);

              // 🔄 CURRENTLY PROCESSING
              if (isProcessing && !isCompleted) {
                return _processingThumb(image);
              }

              // ✅ COMPLETED
              if (isCompleted) {
                return _completedThumb(image);
              }

              // 🖼 NORMAL
              return _imageThumbFromFile(image);
            },
          );
        },
      ),
    );
  }

  Widget _completedThumb(ImageProvider image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image(image: image, fit: BoxFit.cover),
            ),

            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4CAF50),
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _processingThumb(ImageProvider image) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF29B6F6),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // 👈 border से थोड़ा छोटा
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image(
                image: image,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation(
                  Color(0xFF29B6F6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _imageThumbFromFile(ImageProvider image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image(image: image, width: 64, height: 64, fit: BoxFit.cover),
    );
  }

  Widget _pulseIcon() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const PulseRing(delay: 0),
          const PulseRing(delay: 1),
          const PulseRing(delay: 2),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF29B6F6).withOpacity(0.15),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 46,
              color: Color(0xFF29B6F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: overallProgress,
            minHeight: 10,
            backgroundColor: Colors.white12,
            valueColor:
            const AlwaysStoppedAnimation(Color(0xFF29B6F6)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${(overallProgress * 100).round()}% Complete",
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _stepsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2535),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: List.generate(
          processingSteps.length,
          (index) => StepItem(
            title: processingSteps[index].label,
            index: index,
            currentStep: currentStep,
          ),
        ),
      ),
    );
  }
}

