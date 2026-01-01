import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

enum CarPose { front, back, unknown }

class CarCaptureScreen extends StatefulWidget {
  const CarCaptureScreen({super.key});

  @override
  State<CarCaptureScreen> createState() => _CarCaptureScreenState();
}

class _CarCaptureScreenState extends State<CarCaptureScreen> {
  CameraController? _controller;
  bool _isReady = false;
  bool _isInitializing = true;

  int _selectedFrameIndex = 0;

  final List<String> _frameAssets = [
    'assets/images/frame1.png',
    'assets/images/frame2.jpg',
    'assets/images/frame3.jpg',
  ];

  /// ================= ML KIT =================

  final ObjectDetector _detector = ObjectDetector(
    options: ObjectDetectorOptions(
      classifyObjects: true,
      multipleObjects: false,
      mode: DetectionMode.single,
    ),
  );

  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );

  /// ================= LABEL RULES =================

  static const allowedCarLabels = [
    "car",
    "vehicle",
    "motor",
    "automotive",
    "auto",
  ];


  /// ❗ Reject ONLY interior-only images
  static const rejectedViewLabels = [
    "interior",
    "dashboard",
    "steering wheel",
    "seat",
    "gear",
  ];

  static const interiorHints = [
    "dashboard",
    "steering wheel",
    "seat",
    "interior",
  ];

  static const frontHints = [
    "headlight",
    "grille",
    "hood",
    "front bumper",
    "license plate",
    "windshield",
  ];


  static const backHints = [
    "taillight",
    "trunk",
    "rear",
    "rear bumper",
  ];


  /// ================= FRAME =================

  Rect get frameRect => const Rect.fromLTWH(40, 140, 320, 200);

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isReady = true;
        _isInitializing = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Camera init failed");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _detector.close();
    _labeler.close();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  /// ================= CORE LOGIC =================

  bool isFrontOrBackCar(List<ImageLabel> labels) {
    bool hasCar = false;
    bool hasRejected = false;

    for (final label in labels) {
      final name = label.label.toLowerCase();

      debugPrint("🏷 label: ${label.label}");

      // ✅ CAR DETECTION (ROBUST)
      if (allowedCarLabels.any((k) => name.contains(k))) {
        hasCar = true;
      }

      // ❌ INTERIOR-ONLY rejection
      if (rejectedViewLabels.any((k) => name.contains(k))) {
        hasRejected = true;
      }
    }

    debugPrint("🚗 hasCar: $hasCar | 🚫 rejected: $hasRejected");

    return hasCar && !hasRejected;
  }


  CarPose detectCarPose(List<ImageLabel> labels) {
    int frontScore = 0;
    int backScore = 0;

    for (final label in labels) {
      final name = label.label.toLowerCase();
      final confidence = label.confidence;

      // ❌ Interior → reject immediately
      if (interiorHints.any((e) => name.contains(e))) {
        return CarPose.unknown;
      }

      // ➡ FRONT hints
      if (frontHints.any((e) => name.contains(e))) {
        frontScore += (confidence * 10).round();
        debugPrint("➡ FRONT: ${label.label} (${confidence.toStringAsFixed(2)})");
      }

      // ⬅ BACK hints
      if (backHints.any((e) => name.contains(e))) {
        backScore += (confidence * 10).round();
        debugPrint("⬅ BACK: ${label.label} (${confidence.toStringAsFixed(2)})");
      }
    }

    debugPrint("📊 FrontScore=$frontScore | BackScore=$backScore");

    // ✅ Allow FRONT or BACK
    if (frontScore >= 5 && frontScore > backScore) {
      return CarPose.front;
    }

    if (backScore >= 5 && backScore > frontScore) {
      return CarPose.back;
    }

    return CarPose.unknown;
  }



  bool isCarProperlyFramed(Rect carBox) {
    final overlap = carBox.intersect(frameRect);
    if (overlap.isEmpty) return false;

    final ratio =
        (overlap.width * overlap.height) /
            (frameRect.width * frameRect.height);

    debugPrint("📐 overlap ratio: ${ratio.toStringAsFixed(2)}");
    return ratio >= 0.6;
  }

  /// ================= VALIDATION =================

  Future<bool> _validateCar(File image) async {
    final inputImage = InputImage.fromFile(image);

    // 1️⃣ Object detection (car exists)
    final objects = await _detector.processImage(inputImage);
    if (objects.isEmpty) {
      Fluttertoast.showToast(msg: "❌ No car detected");
      return false;
    }

    // 2️⃣ Image labeling (exterior check)
    final labels = await _labeler.processImage(inputImage);
    if (!isFrontOrBackCar(labels)) {
      Fluttertoast.showToast(msg: "❌ Only exterior car images allowed");
      return false;
    }

    // 3️⃣ Pose validation (FRONT or BACK only)
    final pose = detectCarPose(labels);

    if (pose == CarPose.unknown) {
      Fluttertoast.showToast(
        msg: "❌ Only FRONT or BACK car images allowed",
      );
      return false;
    }

    debugPrint("✅ VALID CAR IMAGE | Allowed Pose: $pose");
    return true;
  }


  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final file = File((await _controller!.takePicture()).path);

    final valid = await _validateCar(file);
    if (!valid) return;

    Fluttertoast.showToast(
      msg: "✅ Perfect! Car validated",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// ================= UI =================

  Widget _frameOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Image.asset(
          _frameAssets[_selectedFrameIndex],
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),
          _frameOverlay(),
          Positioned(
            right: 24,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: _capture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.teal,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
