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

  Future<void> _pickImage(BuildContext context) async {
    final file = await PickImage.pickImage(
      context,
      source: ImageSource.both,
    );
    if (file == null) return;

    final selectedFile = file.selectedFiles.firstOrNull;
    if (selectedFile == null) return;
    final compressed =
        await ImageCompress.compressFile(selectedFile.selectedFile);
    final compressedFile = compressed == null ? null : File(compressed.path);
    final newFile = compressedFile ?? selectedFile.selectedFile;
    final compressedBytes = compressedFile == null
        ? null
        : await PickImage.imageBytes(file: compressedFile);
    final bytes = compressedBytes ?? selectedFile.selectedByte;
    onUpload?.call(bytes, newFile);
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => _pickImage.call(context),
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
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: context.reversedAdaptiveColor,
                ),
              ),
              child: const Icon(
                Icons.add,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
