import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:carbgremover/models/CarPose.dart';
import 'package:carbgremover/screens/PreviewScreen.dart';
import 'package:carbgremover/services/VerifyPoseService.dart';
import 'package:carbgremover/services/car_service.dart';
import 'package:carbgremover/widgets/corner_painter.dart';
import 'package:carbgremover/widgets/pose_Item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class CameraCaptureScreen extends StatefulWidget {
  final String carId;

  const CameraCaptureScreen({
    super.key,
    required this.carId,
  });

  @override
  State<CameraCaptureScreen> createState() => _CameraScreenState();
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
                // Navigator.pop(context);
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

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(carId: widget.carId)),
    );
  }

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
    _restoreCapturedImages();
  }

  void _showInvalidPoseDialog(BuildContext context, String message) {
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

  Future<void> _restoreCapturedImages() async {
    try {
      final restoredImages = await CarService.getUploadedPoseImages(
        widget.carId,
      );

      if (!mounted) return;

      setState(() {
        _capturedImages.clear();
        _capturedImages.addAll(restoredImages);

        // move to first incomplete pose
        for (int i = 0; i < poses.length; i++) {
          if (_capturedImages[i]?.isNotEmpty != true) {
            _selectedPoseIndex = i;
            break;
          }
        }
      });

      _checkAllPosesCompleted();
    } catch (e) {
      debugPrint("❌ Restore failed: $e");
    }
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
      final int poseIndex = _selectedPoseIndex;

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
            context,
            result["message"] ?? "Please capture the correct car pose",
          );
        }
        return; // ⛔ STOP
      }

      /// ✅ VALID POSE → SAVE & MOVE NEXT
      if (!mounted) return;

      setState(() {
        _capturedImages.putIfAbsent(poseIndex, () => []);
        _capturedImages[poseIndex]!.add(image);

        if (_selectedPoseIndex < poses.length - 1) {
          _selectedPoseIndex++;
        }
      });

      _scrollToSelectedPose();
      _checkAllPosesCompleted();
      uploadImageInBackground(image: image, poseIndex: poseIndex);
    } catch (e) {
      debugPrint("❌ Capture error: $e");
      Fluttertoast.showToast(msg: "Pose verification failed");
    } finally {
      _isVerifying = false; // 🔓 UNLOCK
    }
  }

  Future<void> uploadImageInBackground({
    required XFile image,
    required int poseIndex,
  }) async {
    try {
      await CarService.uploadSingleImage(
        carId: widget.carId,
        imageFile: image,
        poseIndex: poseIndex,
      );
    } catch (e) {
      debugPrint("❌ Background upload failed: $e");
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

    final int poseIndex = _selectedPoseIndex; // ✅ CAPTURE FIRST

    // ✅ PLACE THE BLOCK HERE
    setState(() {
      _capturedImages.putIfAbsent(poseIndex, () => []);
      _capturedImages[poseIndex]!.add(image);

      if (_selectedPoseIndex < poses.length - 1) {
        _selectedPoseIndex++;
      }
    });

    _scrollToSelectedPose();
    _checkAllPosesCompleted();

    // 🚀 BACKGROUND UPLOAD
    uploadImageInBackground(image: image, poseIndex: poseIndex);
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
                              poses[_selectedPoseIndex].name,
                              // 🔥 selected pose
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
                    child: IgnorePointer(child: _frameOverlay1()),
                  ),
                  Positioned.fill(child: IgnorePointer(child: _frameOverlay())),
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

  Widget _frameOverlay1() {
    return Image.asset(
      poses[_selectedPoseIndex].guideImage,
      fit: BoxFit.contain, // 🔥 VERY IMPORTANT
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
