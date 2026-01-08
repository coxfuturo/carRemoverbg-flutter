import 'dart:io';
import 'dart:typed_data'; // ✅ CORRECT

import 'package:carbgremover/models/BackgroundItem.dart';

class ImageLayer {
  final File original;        // raw camera image
  final File noBg;            // bg removed PNG

  Uint8List? previewBytes;    // live preview (bg + filters)
  Uint8List? finalBytes;      // export-ready

  BackgroundPreset? bg;
  double brightness = 0;
  double contrast = 0;
  double saturation = 0;

  ImageLayer({
    required this.original,
    required this.noBg,
  });
}
