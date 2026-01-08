import 'dart:typed_data';

class CarImage {
  final String url;
  Uint8List? bgRemoved;
  Uint8List? finalImage;
  String background;
  final String imageDocId;
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
