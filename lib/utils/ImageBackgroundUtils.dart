import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:carbgremover/models/BackgroundItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImageBackgroundUtils {

  static Future<Uint8List> applyBackground({
    required Uint8List carPng,
    required BackgroundItem background,
  }) async {
    if (background.id == "transparent") {
      return carPng;
    }

    try {
      // 🔹 Load background image
      final bgData = await rootBundle.load(background.asset);
      final bgCodec = await ui.instantiateImageCodec(
        bgData.buffer.asUint8List(),
      );
      final bgFrame = await bgCodec.getNextFrame();
      final bgImage = bgFrame.image;

      // 🔹 Load car PNG
      final carCodec = await ui.instantiateImageCodec(carPng);
      final carFrame = await carCodec.getNextFrame();
      final carImage = carFrame.image;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      final bgSize = ui.Size(
        bgImage.width.toDouble(),
        bgImage.height.toDouble(),
      );
      final carSize = ui.Size(
        carImage.width.toDouble(),
        carImage.height.toDouble(),
      );

      // 🔹 Draw background
      canvas.drawImage(bgImage, ui.Offset.zero, ui.Paint());

      // 🔹 Maintain aspect ratio
      final fitted = applyBoxFit(
        BoxFit.contain,
        carSize,
        bgSize,
      );

      final dx = (bgSize.width - fitted.destination.width) / 2;
      final dy = (bgSize.height - fitted.destination.height) / 2;

      // 🔹 Draw car centered
      canvas.drawImageRect(
        carImage,
        ui.Rect.fromLTWH(0, 0, carSize.width, carSize.height),
        ui.Rect.fromLTWH(
          dx,
          dy,
          fitted.destination.width,
          fitted.destination.height,
        ),
        ui.Paint(),
      );

      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(
        bgSize.width.toInt(),
        bgSize.height.toInt(),
      );

      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      // 🔥 Free GPU memory
      bgImage.dispose();
      carImage.dispose();
      finalImage.dispose();

      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint("applyBackground error: $e");
      return carPng;
    }
  }
}
