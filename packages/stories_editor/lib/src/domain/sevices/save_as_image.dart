import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stories_editor/src/presentation/utils/image_compress.dart';

Future<dynamic> takePicture({
  required GlobalKey contentKey,
  required BuildContext context,
  required bool saveToGallery,
}) async {
  try {
    final boundary =
        contentKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    final image = await boundary?.toImage(pixelRatio: 3.0);

    final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();
    final compressedBytes = await ImageCompress.compressByte(pngBytes);

    /// create file
    final dir = (await getApplicationDocumentsDirectory()).path;
    final imagePath = '$dir/${DateTime.now()}.png';
    final capturedFile = File(imagePath);
    await capturedFile.writeAsBytes(compressedBytes!);

    if (saveToGallery) {
      final result = await ImageGallerySaver.saveImage(
        pngBytes!,
        quality: 100,
        name: '${DateTime.now()}.png',
      );
      if (result != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return imagePath;
    }
  } catch (e) {
    return false;
  }
}
