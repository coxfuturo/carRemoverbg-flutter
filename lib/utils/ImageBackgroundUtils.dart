import 'dart:ui' as ui;

import 'package:carbgremover/models/BackgroundItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImageBackgroundUtils {
  static Future<Uint8List> applyBackground1({
    required Uint8List carPng,
    required BackgroundItem background,
  }) async
  {
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

  static Future<Uint8List> applyBackground({
    required Uint8List carPng,
    required BackgroundItem background,
  }) async {
    if (background.id == "transparent") return carPng;

    try {
      const double canvasW = 1280;
      const double canvasH = 720;

      // Load background
      final bgData = await rootBundle.load(background.asset);
      final bgFrame = await ui
          .instantiateImageCodec(bgData.buffer.asUint8List())
          .then((c) => c.getNextFrame());
      final bgImage = bgFrame.image;

      // Load car
      final carFrame = await ui
          .instantiateImageCodec(carPng)
          .then((c) => c.getNextFrame());
      final carImage = carFrame.image;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      // ---------- BACKGROUND ----------
      final fitted = applyBoxFit(
        BoxFit.cover,
        Size(bgImage.width.toDouble(), bgImage.height.toDouble()),
        const Size(canvasW, canvasH),
      );

      final srcRect = Rect.fromLTWH(
        (bgImage.width - fitted.source.width) / 2,
        (bgImage.height - fitted.source.height) / 2,
        fitted.source.width,
        fitted.source.height,
      );

      final dstRect = const Rect.fromLTWH(
        0,
        0,
        canvasW,
        canvasH,
      );

      canvas.drawImageRect(bgImage, srcRect, dstRect, Paint());

      // ---------- CAR ----------
      final double targetCarWidth = canvasW * 0.85;
      final double scale = targetCarWidth / carImage.width;

      final double carW = carImage.width * scale;
      final double carH = carImage.height * scale;

      final Offset carOffset = Offset(
        (canvasW - carW) / 2,
        canvasH - carH - 20,
      );

      canvas.save();
      canvas.translate(carOffset.dx, carOffset.dy);
      canvas.scale(scale);
      canvas.drawImage(carImage, Offset.zero, Paint());
      canvas.restore();

      // ---------- EXPORT ----------
      final picture = recorder.endRecording();
      final image =
      await picture.toImage(canvasW.toInt(), canvasH.toInt());
      final bytes =
      await image.toByteData(format: ui.ImageByteFormat.png);

      bgImage.dispose();
      carImage.dispose();
      image.dispose();

      return bytes!.buffer.asUint8List();
    } catch (e) {
      debugPrint("applyBackground error: $e");
      return carPng;
    }
  }


}
