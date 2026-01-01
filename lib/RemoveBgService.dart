import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class RemoveBgService {
  static const String _apiKey = "4JCWqBYf2v2TuxW6LTu9LUXh";

  static Future<Uint8List> removeBackground(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    );

    request.headers['X-Api-Key'] = _apiKey;
    request.files.add(
      await http.MultipartFile.fromPath('image_file', image.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      throw Exception("remove.bg failed");
    }
  }
}
