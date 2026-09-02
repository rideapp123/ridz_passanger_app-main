import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class S3Service {
  factory S3Service() => _instance ??= S3Service._();

  S3Service._();
  static S3Service? _instance;

  static Future<void> uploadImageToS3(Uint8List byte, String url) async {
    // Create a PUT request with the pre-signed URL
    final request = http.Request('PUT', Uri.parse(url));

    // Set content length
    request.headers['Content-Length'] = byte.length.toString();

    // Set content type (if known)
    request.headers['Content-Type'] = 'image/jpeg';

    // Send the file data in the request body
    request.bodyBytes = byte;

    // Send the request
    final response = await request.send();

    // Check if the upload was successful
    if (response.statusCode == 200) {
      debugPrint('Image uploaded successfully');
    } else {
      throw Exception('Image upload failed with status: ${response.statusCode}');
    }
  }
}
