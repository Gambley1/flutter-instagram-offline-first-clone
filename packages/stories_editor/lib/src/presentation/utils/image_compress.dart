import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// {@template image_compress}
/// Allows compressing image files and bytes.
/// {@endtemplate}
class ImageCompress {
  const ImageCompress._();

  /// Compress image byte.
  static Future<Uint8List?> compressByte(Uint8List? file) async {
    if (file == null) return null;
    if (file.lengthInBytes > 200000) {
      final result = await FlutterImageCompress.compressWithList(
        file,
        quality: file.lengthInBytes > 4000000 ? 90 : 72,
      );
      return result;
    } else {
      return file;
    }
  }

  /// Compress image file.
  static Future<XFile?> compressFile(File? file, {int quality = 5}) async {
    if (file == null) return null;
    final filePath = file.absolute.path;

    final lastIndex = filePath.lastIndexOf(RegExp('.jp'));
    if (lastIndex == -1) {
      return null;
    }
    final split = filePath.substring(0, lastIndex);
    final outPath = '${split}_out${filePath.substring(lastIndex)}';
    return FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: quality,
    );
  }
}
