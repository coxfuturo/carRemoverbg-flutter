import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class CarImage {
  /// Original captured image
  final XFile original;

  /// Background removed PNG (transparent)
  Uint8List? bgRemoved;

  /// Final image after applying background/frame
  Uint8List? finalImage;

  /// Selected background id
  String background;

  CarImage({
    required this.original,
    this.bgRemoved,
    this.finalImage,
    this.background = "transparent",
  });
}
