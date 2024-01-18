// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:app_ui/app_ui.dart' hide AppTheme;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
// import 'package:images_picker/images_picker.dart';

class PickImage {
  /// {@macro image_picker}
  const PickImage._();

  static AppTheme _appTheme(BuildContext context) => AppTheme(
        focusColor: Colors.white,
        primaryColor: Colors.black,
      );

  static TabsTexts _tabsTexts(BuildContext context) => TabsTexts();

  static SliverGridDelegateWithFixedCrossAxisCount _sliverGridDelegate() =>
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 1.7,
        mainAxisSpacing: 1.5,
      );

  static ImagePickerPlus _imagePickerPlus(BuildContext context) =>
      ImagePickerPlus(context);

  static Future<List<AssetEntity>?> pickAssets(
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

  static Future<void> pickAssetsFromBoth(
    BuildContext context, {
    required Future<void> Function(
      BuildContext context,
      SelectedImagesDetails,
    ) onMediaPicked,
    bool cropImage = true,
    bool showPreview = true,
    int maxSelection = 10,
    bool multiSelection = true,
  }) =>
      _imagePickerPlus(context).pickBoth(
        source: ImageSource.both,
        multiSelection: multiSelection,
        galleryDisplaySettings: GalleryDisplaySettings(
          maximumSelection: maxSelection,
          showImagePreview: showPreview,
          cropImage: cropImage,
          tabsTexts: _tabsTexts(context),
          appTheme: _appTheme(context),
          callbackFunction: (details) => onMediaPicked.call(context, details),
        ),
      );

  static Future<SelectedImagesDetails?> pickImage(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
    int maxSelection = 1,
    bool cropImage = true,
    bool multiImages = false,
    bool showPreview = true,
  }) =>
      _imagePickerPlus(context).pickImage(
        source: source,
        multiImages: multiImages,
        galleryDisplaySettings: GalleryDisplaySettings(
          cropImage: cropImage,
          maximumSelection: maxSelection,
          showImagePreview: showPreview,
          tabsTexts: _tabsTexts(context),
          appTheme: _appTheme(context),
          gridDelegate: _sliverGridDelegate(),
        ),
      );

  static Future<void> pickVideo(
    BuildContext context, {
    required Future<void> Function(
      BuildContext context,
      SelectedImagesDetails,
    ) onMediaPicked,
    ImageSource source = ImageSource.both,
    int maxSelection = 10,
    bool cropImage = true,
    bool multiImages = false,
    bool showPreview = true,
  }) async {
    await _imagePickerPlus(context).pickVideo(
      source: source,
      galleryDisplaySettings: GalleryDisplaySettings(
        showImagePreview: showPreview,
        cropImage: cropImage,
        maximumSelection: maxSelection,
        tabsTexts: _tabsTexts(context),
        appTheme: _appTheme(context),
        callbackFunction: (details) => onMediaPicked.call(context, details),
      ),
    );
  }

  /// Reads image as bytes.
  static Future<Uint8List> imageBytes({required File file}) =>
      compute((file) => file.readAsBytes(), file);
}
