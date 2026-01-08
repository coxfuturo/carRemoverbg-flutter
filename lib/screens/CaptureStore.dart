import 'package:carbgremover/models/CarImage.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data'; // ✅ CORRECT

class CaptureStore extends ChangeNotifier {
  final List<CarImage> _images = [];

  List<CarImage> get images => _images;
  int get capturedCount => _images.length;

  // =========================
  // ADD IMAGE
  // =========================
  void addImage(CarImage image) {
    _images.add(image);
    notifyListeners();
  }

  // =========================
  // BG REMOVED
  // =========================
  void saveNoBgImage(int poseIndex, Uint8List bytes) {
    final img = _images.firstWhere(
          (e) => e.poseIndex == poseIndex,
    );
    img.bgRemoved = bytes;
    notifyListeners();
  }

  CarImage? getByPoseIndex(int poseIndex) {
    try {
      return _images.firstWhere(
            (e) => e.poseIndex == poseIndex,
      );
    } catch (_) {
      return null;
    }
  }


  // =========================
  // BG APPLIED
  // =========================
  void saveFinalImage(
      int poseIndex,
      Uint8List bytes, {
        required String backgroundName,
      }) {
    final index =
    _images.indexWhere((e) => e.poseIndex == poseIndex);

    if (index == -1) return;

    _images[index] = CarImage(
      url: _images[index].url,
      imageDocId: _images[index].imageDocId,
      poseIndex: poseIndex,
      bgRemoved: _images[index].bgRemoved,
      finalImage: bytes,
      background: backgroundName,
    );

    notifyListeners();
  }


  // =========================
  // GETTERS
  // =========================
  CarImage? getByPose(int poseIndex) {
    try {
      return _images.firstWhere(
            (e) => e.poseIndex == poseIndex,
      );
    } catch (_) {
      return null;
    }
  }

  bool hasImageForPose(int poseIndex) {
    return _images.any((e) => e.poseIndex == poseIndex);
  }


  void upsertImage(CarImage image) {
    final index =
    _images.indexWhere((e) => e.poseIndex == image.poseIndex);

    if (index != -1) {
      _images[index] = image; // replace
    } else {
      _images.add(image); // add new
    }
    notifyListeners();
  }


  // =========================
  // REMOVE / CLEAR
  // =========================
  void removeImage(int poseIndex) {
    _images.removeWhere((e) => e.poseIndex == poseIndex);
    notifyListeners();
  }

  void clearAll() {
    _images.clear();
    notifyListeners();
  }
}
