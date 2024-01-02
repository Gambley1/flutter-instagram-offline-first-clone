import 'dart:io';
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class AvatarImagePicker extends StatelessWidget {
  const AvatarImagePicker({
    this.compress = true,
    this.radius = 64,
    this.addButtonRadius = 18,
    this.placeholderSize = 54,
    this.withPlaceholder = true,
    this.onUpload,
    super.key,
    this.imageBytes,
  });

  final Uint8List? imageBytes;
  final void Function(Uint8List, File)? onUpload;
  final bool compress;
  final double radius;
  final double addButtonRadius;
  final double placeholderSize;
  final bool withPlaceholder;

  Future<void> _pickImage() async {
    final file = await PickImage.imageWithImagePicker(
      source: ImageSource.gallery,
      compress: compress,
    );
    if (file == null) return;
    final imageBytes = await PickImage.imageBytes(file: file);
    onUpload?.call(imageBytes, file);
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade500,
            backgroundImage:
                imageBytes == null ? null : MemoryImage(imageBytes!),
            child: imageBytes != null
                ? null
                : withPlaceholder
                    ? Icon(
                        Icons.person,
                        size: placeholderSize,
                      )
                    : null,
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: CircleAvatar(
              radius: addButtonRadius,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
