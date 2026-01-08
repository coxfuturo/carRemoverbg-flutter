import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class RemoveBgService {
  static const String _apiKey = "xNFCyowh71RKVT2dU7vS6k7z";


  // ============================================
  // 🔥 REMOVE BG FROM LOCAL FILE (OLD – SAFE)
  // ============================================
  static Future<Uint8List> removeBackground(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    );

    request.headers['X-Api-Key'] = _apiKey;
    request.files.add(
      await http.MultipartFile.fromPath(
        'image_file',
        image.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      throw Exception("remove.bg failed");
    }
  }

  // ============================================
  // 🔥 REMOVE BG FROM BYTES (URL / FIREBASE IMAGE)
  // ============================================
  static Future<Uint8List> removeBackgroundFromBytes(
      Uint8List imageBytes,
      ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    );

    request.headers['X-Api-Key'] = _apiKey;

    request.files.add(
      http.MultipartFile.fromBytes(
        'image_file',
        imageBytes,
        filename: 'image.png',
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      throw Exception("remove.bg failed");
    }
  }
}
