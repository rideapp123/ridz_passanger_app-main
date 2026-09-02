import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridzs_passenger_app/view/widgets/pick_image_source_widget.dart';

class ImagePickerHelper {
  static Future<String> pickImageFrom(ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: imageSource,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 75,
    );

    if (image == null) return "";

    // File rotatedImage =
    //     await FlutterExifRotation.rotateAndSaveImage(path: image.path);

    return image.path;
  }

  static Future<List<XFile>> pickMultiImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    return images;
  }

  static Future<String> getFileSize(String filePath) async {
    final File file = File(filePath);
    final int sizeInBytes = await file.length();
    final String size = formatFileSize(sizeInBytes);
    return size;
  }

  static formatFileSize(int sizeInBytes) {
    if (sizeInBytes <= 0) return "0 B";
    const List<String> units = ["B", "KB", "MB", "GB", "TB"];
    int unitIndex = 0;
    double size = sizeInBytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return "${size.toStringAsFixed(2)} ${units[unitIndex]}";
  }

  static Future<ImageSource?> imageSourceBottomSheet({
    required BuildContext context,
  }) async {
    final imageSource = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => const PickImageSourceWidget(),
    );

    return imageSource;
  }
}
