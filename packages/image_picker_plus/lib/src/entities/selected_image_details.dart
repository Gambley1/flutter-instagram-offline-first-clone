import 'dart:io';

import 'package:flutter/foundation.dart';

class SelectedImagesDetails {
  final List<SelectedByte> selectedFiles;
  final double aspectRatio;
  final bool multiSelectionMode;

  SelectedImagesDetails({
    required this.selectedFiles,
    required this.aspectRatio,
    required this.multiSelectionMode,
  });
}

class SelectedByte {
  final File selectedFile;
  final Uint8List selectedByte;

  final bool isThatImage;

  SelectedByte({
    required this.isThatImage,
    required this.selectedFile,
    required this.selectedByte,
  });
}
