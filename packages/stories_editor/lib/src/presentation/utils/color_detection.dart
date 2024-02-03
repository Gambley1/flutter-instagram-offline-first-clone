import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ColorDetection {
  final GlobalKey? currentKey;
  final StreamController<Color>? stateController;
  final GlobalKey? paintKey;

  img.Image? photo;

  ColorDetection({
    required this.currentKey,
    required this.stateController,
    required this.paintKey,
  });

  Future<dynamic> searchPixel(Offset globalPosition) async {
    if (photo == null) {
      await loadSnapshotBytes();
    }
    return _calculatePixel(globalPosition);
  }

  _calculatePixel(Offset globalPosition) {
    RenderBox box = currentKey!.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);

    double px = localPosition.dx;
    double py = localPosition.dy;

    final pixel32 =
        photo!.getPixelSafe(px.toInt(), py.toInt()).toList().cast<int>();
    final hex = pixel32ToArgb(pixel32);

    stateController?.add(Color(hex).withOpacity(.95));
    return Color(hex).withOpacity(.95);
  }

  Future<void> loadSnapshotBytes() async {
    RenderRepaintBoundary? boxPaint =
        paintKey!.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    ui.Image capture = await boxPaint!.toImage();
    ByteData? imageBytes =
        await capture.toByteData(format: ui.ImageByteFormat.png);
    setImageBytes(imageBytes!);
    capture.dispose();
  }

  void setImageBytes(ByteData imageBytes) {
    Uint8List values = imageBytes.buffer.asUint8List();
    photo = null;
    photo = img.decodeImage(values);
  }
}

// image lib uses KML color format, convert #AABBGGRR to regular #AARRGGBB
int abgrToArgb(int argbColor) {
  int r = (argbColor >> 16) & 0xFF;
  int b = argbColor & 0xFF;
  return (argbColor & 0xFF00FF00) | (b << 16) | r;
}

int pixel32ToArgb(List<int> pixel) {
  if (pixel.length != 4) {
    throw ArgumentError('Pixel must have four components.');
  }

  // Shift and pack the channels into a single integer in ARGB format
  return (pixel[3] << 24) | (pixel[0] << 16) | (pixel[1] << 8) | pixel[2];
}