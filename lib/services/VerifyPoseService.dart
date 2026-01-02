import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> verifyPose({
  required File imageFile,
  required String expectedLabel,
}) async {
  final uri = Uri.parse("https://coxfuture.com/fastapi/verify_poses");

  final request = http.MultipartRequest("POST", uri);

  request.fields["expected_label"] = expectedLabel;

  request.files.add(await http.MultipartFile.fromPath("image", imageFile.path));

  debugPrint("➡️ VERIFY POSE API CALL");
  debugPrint("URL: $uri");
  debugPrint("Expected label: $expectedLabel");
  debugPrint("Image path: ${imageFile.path}");

  final response = await request.send();

  final statusCode = response.statusCode;
  final responseBody = await response.stream.bytesToString();

  debugPrint("⬅️ STATUS CODE: $statusCode");
  debugPrint("⬅️ RESPONSE BODY: $responseBody");

  if (statusCode == 200) {
    return jsonDecode(responseBody);
  } else {
    return {"success": false, "statusCode": statusCode, "error": responseBody};
  }
}
