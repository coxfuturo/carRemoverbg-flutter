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

      final carSize = ui.Size(
        carImage.width.toDouble(),
        carImage.height.toDouble(),
      );

      final bgSize = ui.Size(
        bgImage.width.toDouble(),
        bgImage.height.toDouble(),
      );

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      // 🔹 Resize background to COVER car size
      final fittedBg = applyBoxFit(
        BoxFit.cover,
        bgSize,
        carSize,
      );

      final bgDx = (carSize.width - fittedBg.destination.width) / 2;
      final bgDy = (carSize.height - fittedBg.destination.height) / 2;

      // 🔹 Draw background (scaled)
      canvas.drawImageRect(
        bgImage,
        ui.Rect.fromLTWH(0, 0, bgSize.width, bgSize.height),
        ui.Rect.fromLTWH(
          bgDx,
          bgDy,
          fittedBg.destination.width,
          fittedBg.destination.height,
        ),
        ui.Paint(),
      );

      // 🔹 Draw car at ORIGINAL SIZE (no scaling)
      canvas.drawImage(
        carImage,
        ui.Offset.zero,
        ui.Paint(),
      );

      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(
        carSize.width.toInt(),
        carSize.height.toInt(),
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
