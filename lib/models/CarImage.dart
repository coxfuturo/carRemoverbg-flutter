import 'dart:typed_data';

class CarImage {
  /// Firebase image URL (source of truth)
  final String url;

  /// Background removed PNG bytes
  Uint8List? bgRemoved;

  /// Final image after applying background
  Uint8List? finalImage;

  /// Selected background id
  String background;

  /// Firestore document id (for update/delete)
  final String imageDocId;

  /// Pose index (ordering)
  final int poseIndex;

  CarImage({
    required this.url,
    required this.imageDocId,
    required this.poseIndex,
    this.bgRemoved,
    this.finalImage,
    this.background = "transparent",
  });
}
