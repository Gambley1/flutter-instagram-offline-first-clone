// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:shared/shared.dart';

class PickImage {
  /// {@macro image_picker}
  const PickImage._();

  static final _imagePicker = ImagePicker();

  static final _filePicker = FilePicker.platform;

  static Future<List<AssetEntity>?> pickFiles(
    BuildContext context, {
    required ValueSetter<Stream<InstaAssetsExportDetails>> onCompleted,
    int maxAssets = 10,
    bool closeOnComplete = false,
  }) =>
      InstaAssetPicker.pickAssets(
        context,
        pickerTheme: context.theme,
        onCompleted: onCompleted,
        maxAssets: maxAssets,
        closeOnComplete: closeOnComplete,
      );

  /// Pick image with image picker from `source` (Gallery or Camera).
  static Future<XFile?> imageWithXImagePicker({
    required ImageSource source,
    double? maxHeight,
    double? maxWidth,
    bool requestFullMetaData = true,
    bool compress = true,
  }) async {
    final file = await _imagePicker.pickImage(
      source: source,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      requestFullMetadata: requestFullMetaData,
    );
    if (file == null) return null;
    final imageFile = File(file.path);
    if (!compress) return file;
    logD('Compressing image...');

    final compressedImage = await compressFile(imageFile);
    if (compressedImage == null) return file;
    return compressedImage;
  }

  /// Pick image with image picker from `source` (Gallery or Camera).
  static Future<File?> imageWithImagePicker({
    required ImageSource source,
    double? maxHeight,
    double? maxWidth,
    bool requestFullMetaData = true,
    bool compress = true,
  }) async {
    final file = await _imagePicker.pickImage(
      source: source,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      requestFullMetadata: requestFullMetaData,
    );
    if (file == null) return null;
    final imageFile = File(file.path);
    if (!compress) return imageFile;
    logD('Compressing image...');

    final compressedImage = await compressFile(imageFile);
    if (compressedImage == null) return imageFile;
    return File(compressedImage.path);
  }

  /// Pick image with image picker from `source` (Gallery or Camera).
  static Future<List<File>> multipleImagesWithImagePicker({
    double? maxHeight,
    double? maxWidth,
    bool requestFullMetaData = true,
    bool compress = false,
  }) async {
    final files = await _imagePicker.pickMultiImage(
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      requestFullMetadata: requestFullMetaData,
    );
    if (files.isEmpty) return <File>[];

    final imagesFile = <File>[];
    for (final file in files) {
      final imageFile = File(file.path);
      if (!compress) {
        imagesFile.add(imageFile);
        continue;
      }
      logD('Compressing image...');

      final compressedImage = await compressFile(imageFile);
      if (compressedImage == null) {
        imagesFile.add(imageFile);
        continue;
      }
      final compressedImageFile = File(compressedImage.path);

      imagesFile.add(compressedImageFile);
    }
    return imagesFile;
  }

  /// Pick image from `source` (Gallery or Camera).
  static Future<File?> imageWithFilePicker({
    bool compress = true,
  }) async {
    final picker = await _filePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpeg', 'jpg', 'png'],
    );
    if (picker == null || picker.files.isEmpty) return null;

    final file = picker.files.first;
    final imageFile = File(file.path!);
    if (!compress) return imageFile;
    logD('Compressing image...');

    final compressedImage = await compressFile(imageFile);
    if (compressedImage == null) return imageFile;
    return File(compressedImage.path);
  }

  /// Reads image as bytes.
  static Future<Uint8List> imageBytes({required File file}) =>
      compute((file) => file.readAsBytes(), file);

  /// Compresses file.
  static Future<XFile?> compressFile(
    File file, {
    int quality = 5,
  }) async {
    final filePath = file.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(RegExp('.jp'));
    if (lastIndex == -1) {
      return null;
    }
    final splitted = filePath.substring(0, lastIndex);
    final outPath = '${splitted}_out${filePath.substring(lastIndex)}';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: quality,
    );

    return result;
  }
}
