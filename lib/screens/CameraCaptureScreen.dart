import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:carbgremover/models/CarImage.dart';
import 'package:carbgremover/models/CarPose.dart';
import 'package:carbgremover/screens/CaptureStore.dart';
import 'package:carbgremover/screens/new_preview_screen.dart';
import 'package:carbgremover/utils/Routes.dart';
import 'package:carbgremover/widgets/corner_painter.dart';
import 'package:carbgremover/widgets/pose_Item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _poseScrollController = ScrollController();

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

  void _selectPose(int index) {
    setState(() {
      _selectedPoseIndex = index;
    });

    _scrollToSelectedPose();
  }

  Future<void> _captureImage() async {
    if (!_controller.value.isInitialized ||
        _controller.value.isTakingPicture ||
        _isVerifying) {
      return;
    }

    _isVerifying = true;

    try {
      final XFile image = await _controller.takePicture();

      _audioPlayer.play(AssetSource('sound/camera_audio.mp3'));

      final int poseIndex = _selectedPoseIndex;

      final carImage = CarImage(
        url: image.path,
        imageDocId: DateTime.now().millisecondsSinceEpoch.toString(),
        poseIndex: poseIndex,
      );

      context.read<CaptureStore>().upsertImage(carImage);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewPreviewScreen(image: image, angleIndex: poseIndex),
        ),
      );

      if (result == null) return;

      if (result == "next") {
        if (_selectedPoseIndex < poses.length - 1) {
          setState(() => _selectedPoseIndex++);
          _scrollToSelectedPose();
        } else {
          Navigator.pushNamed(context, Routes.reviewPhotosScreen);
        }
      }
    } catch (e) {
      debugPrint("❌ Capture error: $e");
      Fluttertoast.showToast(msg: "Failed to capture image");
    } finally {
      _isVerifying = false;
    }
  }

  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final int poseIndex = _selectedPoseIndex;

    final carImage = CarImage(
      url: image.path,
      imageDocId: DateTime.now().millisecondsSinceEpoch.toString(),
      poseIndex: poseIndex,
    );

    context.read<CaptureStore>().upsertImage(carImage);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewPreviewScreen(image: image, angleIndex: poseIndex),
      ),
    );

    if (result == null) return;

    if (result == "next") {
      if (_selectedPoseIndex < poses.length - 1) {
        setState(() => _selectedPoseIndex++);
        _scrollToSelectedPose();
      } else {
        Navigator.pushNamed(context, Routes.reviewPhotosScreen);
      }
    }
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
            SizedBox(
              width: 120,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<CaptureStore>(
                  builder: (context, store, _) {
                    return ListView.separated(
                      controller: _poseScrollController,
                      itemCount: poses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final bool isCompleted = store.hasImageForPose(index);

                        return PoseItem(
                          title: poses[index].name,
                          image: poses[index].guideImage,
                          selected: index == _selectedPoseIndex,
                          completed: isCompleted,
                          onTap: () => _selectPose(index),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            /// 🟥 CENTER – CAMERA PREVIEW
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
                      children: [
                        /// CLOSE BUTTON
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        /// CENTER TEXT (FIXED)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  poses[_selectedPoseIndex].name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${_selectedPoseIndex + 1}/${poses.length}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// RIGHT SPACER
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  /// FRAME OVERLAY
                  Positioned.fill(
                    child: IgnorePointer(child: _frameOverlay1()),
                  ),
                  Positioned.fill(child: IgnorePointer(child: _frameOverlay())),
                ],
              ),
            ),

            /// 🟩 RIGHT – CONTROLS
            SizedBox(
              width: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// FLASH
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

                  /// CAPTURE
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
                  Text(
                    context.watch<CaptureStore>().images.length.toString(),
                    style: const TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 20),

                  /// Review
                  _circleIconButton(
                    icon: Icons.upload,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.reviewPhotosScreen);
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
      fit: BoxFit.contain,
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
