import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

class ImageExportFromStoreService {
  static const String _downloadDir = "/storage/emulated/0/Download";

  /// 🔹 Get bytes priority: finalImage > bgRemoved
  static Uint8List? _getBytes(dynamic img) {
    return img.finalImage ?? img.bgRemoved;
  }

  /// ===============================
  /// ✅ SAVE SINGLE IMAGE
  /// ===============================
  static Future<String> saveSingleImage({
    required Uint8List bytes,
    required int poseIndex,
  }) async {
    final file = File(
      "$_downloadDir/car_pose_$poseIndex.png",
    );

    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// ===============================
  /// ✅ SAVE ALL IMAGES (INDIVIDUAL FILES)
  /// ===============================
  static Future<List<String>> saveAllImages(
      List images,
      ) async {
    final List<String> paths = [];

    for (final img in images) {
      final Uint8List? bytes = _getBytes(img);
      if (bytes == null) continue;

      final file = File(
        "$_downloadDir/car_pose_${img.poseIndex}.png",
      );

      await file.writeAsBytes(bytes, flush: true);
      paths.add(file.path);
    }

    return paths;
  }

  /// ===============================
  /// ✅ SAVE ALL IMAGES AS ZIP
  /// ===============================
  static Future<String> saveAsZip(
      List images,
      String zipName,
      ) async {
    final archive = Archive();

    for (final img in images) {
      final Uint8List? bytes = _getBytes(img);
      if (bytes == null) continue;

      archive.addFile(
        ArchiveFile(
          "pose_${img.poseIndex}.png",
          bytes.length,
          bytes,
        ),
      );
    }

    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception("ZIP creation failed");
    }

    final zipFile = File(
      p.join(_downloadDir, "$zipName.zip"),
    );

    await zipFile.writeAsBytes(zipData, flush: true);
    return zipFile.path;
  }
}
