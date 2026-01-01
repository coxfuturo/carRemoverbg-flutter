import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:carbgremover/CarImage.dart';
import 'package:carbgremover/PreviewScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraScreenState();
}


class CarPose {
  final String name;
  final String guideImage;

  const CarPose({
    required this.name,
    required this.guideImage,
  });
}


class _CameraScreenState extends State<CameraCaptureScreen> {

  late CameraController _controller;
  bool _isReady = false;
  bool _isInitializing = true;
  bool _isFlashOn = false;
  final ImagePicker _picker = ImagePicker();
  int _selectedPoseIndex = 0;
  final Map<int, List<XFile>> _capturedImages = {};
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _poseScrollController = ScrollController();
  bool _allPosesCompletedShown = false;

  void _showAllPosesCompletedDialog() {
    if (_allPosesCompletedShown) return;

    _allPosesCompletedShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0E2235),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                "All Poses Completed",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            "You’ve successfully captured all required car poses.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29B6F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                openPreviewScreen();
              },

              child: const Text("Next", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }



  void openPreviewScreen() {
    final List<CarImage> images = _capturedImages.values
        .expand((list) => list)
        .map((xfile) => CarImage(original: xfile))
        .toList();

    if (images.isEmpty) {
      Fluttertoast.showToast(msg: "Please capture at least one image");
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(images: images)),
    );
  }


  final List<CarPose> poses = [
    CarPose(name: "Front", guideImage: "assets/images/front.png"),
    CarPose(name: "Front Left", guideImage: "assets/images/frontLeft.png"),
    CarPose(name: "Front Right", guideImage: "assets/images/frontRight.png"),

    CarPose(name: "Left Side", guideImage: "assets/images/left_side.png"),
    CarPose(name: "Right Side", guideImage: "assets/images/rightSide.png"),

    CarPose(name: "Back Left", guideImage: "assets/images/backLeft.png"),
    CarPose(name: "BACK", guideImage: "assets/images/back.png"),
    CarPose(name: "Back Right", guideImage: "assets/images/backRight.png"),

    CarPose(name: "Interior Dashboard", guideImage: "assets/images/dashboard.png"),
  ];

  bool _isVerifying = false;


  @override
  void initState() {
    super.initState();

    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setVolume(1.0);

    /// 🔒 LOCK LANDSCAPE
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initCamera();
  }


  Future<Map<String, dynamic>> verifyPose({
    required File imageFile,
    required String expectedLabel,
  }) async {
    final uri = Uri.parse(
      "https://coxfuture.com/fastapi/verify_poses",
    );

    final request = http.MultipartRequest("POST", uri);

    request.fields["expected_label"] = expectedLabel;

    request.files.add(
      await http.MultipartFile.fromPath(
        "image",
        imageFile.path,
      ),
    );

    debugPrint("➡️ VERIFY POSE API CALL");
    debugPrint("URL: $uri");
    debugPrint("Expected label: $expectedLabel");
    debugPrint("Image path: ${imageFile.path}");

    final response = await request.send();

    final statusCode = response.statusCode;
    final responseBody = await response.stream.bytesToString();

    debugPrint("⬅️ STATUS CODE: $statusCode");
    debugPrint("⬅️ RESPONSE BODY: $responseBody");

    if (statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      return {
        "success": false,
        "statusCode": statusCode,
        "error": responseBody,
      };
    }
  }



  void _showInvalidPoseDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Invalid Pose ❌"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _captureImage() async {
    if (!_controller.value.isInitialized ||
        _controller.value.isTakingPicture ||
        _isVerifying) {
      return;
    }

    _isVerifying = true; // 🔒 LOCK CAPTURE

    try {
      /// 📸 Capture image
      final XFile image = await _controller.takePicture();
      final File imageFile = File(image.path);

      /// 🔊 Play shutter sound
      _audioPlayer.play(AssetSource('sound/camera_audio.mp3'));

      /// 🎯 Expected pose
      final String expectedPose = poses[_selectedPoseIndex].name;
      debugPrint("➡️ Verifying pose: $expectedPose");

      /// 🔍 VERIFY POSE
      final result = await verifyPose(
        imageFile: imageFile,
        expectedLabel: expectedPose,
      );

      /// ✅ SAFE BOOLEAN CHECK
      final bool isMatch = result["data"]?["match"] == true;


      /// ❌ INVALID POSE
      if (!isMatch) {
        if (mounted) {
          _showInvalidPoseDialog(
            result["message"] ?? "Please capture the correct car pose",
          );
        }
        return; // ⛔ STOP
      }

      /// ✅ VALID POSE → SAVE & MOVE NEXT
      if (!mounted) return;

      setState(() {
        _capturedImages.putIfAbsent(_selectedPoseIndex, () => []);
        _capturedImages[_selectedPoseIndex]!.add(image);

        if (_selectedPoseIndex < poses.length - 1) {
          _selectedPoseIndex++;
        }
      });

      _scrollToSelectedPose();
      _checkAllPosesCompleted();

    } catch (e) {
      debugPrint("❌ Capture error: $e");
      Fluttertoast.showToast(msg: "Pose verification failed");
    } finally {
      _isVerifying = false; // 🔓 UNLOCK
    }
  }



  Future<void> _captureImage11111() async {
    if (!_controller.value.isInitialized || _controller.value.isTakingPicture) {
      return;
    }

    try {
      /// 📸 CAPTURE FIRST
      final XFile image = await _controller.takePicture();

      /// 🔊 PLAY SHUTTER SOUND
      _audioPlayer.play(AssetSource('sound/camera_audio.mp3'));

      /// ✅ UPDATE STATE
      setState(() {
        _capturedImages.putIfAbsent(_selectedPoseIndex, () => []);
        _capturedImages[_selectedPoseIndex]!.add(image);

        /// AUTO MOVE TO NEXT POSE
        if (_selectedPoseIndex < poses.length - 1) {
          _selectedPoseIndex++;
        }
      });
      _scrollToSelectedPose();
      _checkAllPosesCompleted();
    } catch (e) {
      debugPrint("Capture error: $e");
      Fluttertoast.showToast(msg: "Failed to capture image");
    }
  }


  void _selectPose(int index) {
    setState(() {
      _selectedPoseIndex = index;
    });

    _scrollToSelectedPose();
  }

  int getPoseCount(int index) {
    return _capturedImages[index]?.length ?? 0;
  }

  void _scrollToSelectedPose() {
    const double itemHeight = 90; // PoseItem height
    const double separatorHeight = 12;

    final double offset = _selectedPoseIndex * (itemHeight + separatorHeight);

    _poseScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _capturedImages.putIfAbsent(_selectedPoseIndex, () => []);
      _capturedImages[_selectedPoseIndex]!.add(image);

      /// AUTO MOVE TO NEXT POSE
      if (_selectedPoseIndex < poses.length - 1) {
        _selectedPoseIndex++;
      }
    });

    _scrollToSelectedPose();

    /// CHECK COMPLETION
    _checkAllPosesCompleted();
  }

  void _checkAllPosesCompleted() {
    final allCompleted = List.generate(
      poses.length,
      (i) => _capturedImages[i]?.isNotEmpty == true,
    ).every((e) => e);

    if (allCompleted) {
      Fluttertoast.showToast(msg: "All poses captured ✅");
      _showAllPosesCompletedDialog();
    }
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
    _poseScrollController.dispose();
    _audioPlayer.dispose();
    _controller.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Widget _frameOverlay1() {
    return Image.asset(
      poses[_selectedPoseIndex].guideImage,
      fit: BoxFit.contain, // 🔥 VERY IMPORTANT
    );
  }


  Widget _frameOverlay2() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Image.asset(
          poses[_selectedPoseIndex].guideImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          children: [
            /// LEFT POSE SELECTOR
            SizedBox(
              width: 120,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                  controller: _poseScrollController,
                  itemCount: poses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return PoseItem(
                      title: poses[index].name,
                      image: poses[index].guideImage,
                      selected: index == _selectedPoseIndex,
                      completed: _capturedImages[index]?.isNotEmpty == true,
                      onTap: () => _selectPose(index),
                    );
                  },
                ),
              ),
            ),

            /// 🔴 CAMERA PREVIEW AREA (CENTER ONLY)
            Expanded(
              child: Stack(
                children: [
                  /// CAMERA PREVIEW
                  if (_isInitializing)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else if (_isReady)
                    Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: CameraPreview(_controller),
                      ),
                    ),

                  /// TOP BAR
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(
                              0.12,
                            ), // light white background
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        Row(
                          children: [
                            Text(
                              poses[_selectedPoseIndex].name, // 🔥 selected pose
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${_selectedPoseIndex + 1}/${poses.length}",
                              // example counter
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        Text(""),
                      ],
                    ),
                  ),

                  /// GUIDE TEXT


                  /// FRAME OVERLAY
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _frameOverlay1(),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _frameOverlay(),
                    ),
                  ),

                ],
              ),
            ),

            SizedBox(
              width: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// FLASH BUTTON
                  _circleIconButton(
                    icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    onTap: () async {
                      setState(() {
                        _isFlashOn = !_isFlashOn;
                      });

                      await _controller.setFlashMode(
                        _isFlashOn ? FlashMode.torch : FlashMode.off,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  /// CAPTURE BUTTON
                  GestureDetector(
                    onTap: _captureImage,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// COUNTER
                  const Text("0", style: TextStyle(color: Colors.white54)),

                  const SizedBox(height: 20),

                  /// GALLERY BUTTON
                  _circleIconButton(
                    icon: Icons.photo_library_outlined,
                    onTap: () async {
                      pickFromGallery();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  static Widget _frameOverlay() {
    return SizedBox(
      width: 500,
      height: 300,
      child: Stack(
        children: [
          _corner(Alignment.topLeft),
          _corner(Alignment.topRight),
          _corner(Alignment.bottomLeft),
          _corner(Alignment.bottomRight),
        ],
      ),
    );
  }

  static Widget _corner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 40,
        height: 40,
        child: CustomPaint(painter: CornerPainter(alignment)),
      ),
    );
  }
}

class PoseItem extends StatelessWidget {
  final String title;
  final String image;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const PoseItem({
    super.key,
    required this.title,
    required this.selected,
    required this.completed,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;

    if (completed) {
      borderColor = Colors.green; // ✅ completed
    } else if (selected) {
      borderColor = const Color(0xFF29B6F6); // selected
    } else {
      borderColor = Colors.white24;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF0E2235),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: completed || selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                    height: 40,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: completed
                          ? Colors.green
                          : selected
                          ? Colors.white
                          : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            /// ✅ CHECK ICON
            if (completed)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.check_circle, color: Colors.green, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  final Alignment alignment;

  CornerPainter(this.alignment);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final double w = size.width;
    final double h = size.height;

    if (alignment == Alignment.topLeft) {
      // ┌
      canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
      canvas.drawLine(Offset(0, 0), Offset(0, h), paint);
    } else if (alignment == Alignment.topRight) {
      // ┐
      canvas.drawLine(Offset(w, 0), Offset(0, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
    } else if (alignment == Alignment.bottomLeft) {
      // └
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
      canvas.drawLine(Offset(0, h), Offset(0, 0), paint);
    } else if (alignment == Alignment.bottomRight) {
      // ┘
      canvas.drawLine(Offset(w, h), Offset(0, h), paint);
      canvas.drawLine(Offset(w, h), Offset(w, 0), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
