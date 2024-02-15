// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:app_ui/app_ui.dart' hide AppTheme;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:shared/shared.dart';

class PickImage {
  /// {@macro image_picker}
  const PickImage._();

  static final _defaultFilterOption = FilterOptionGroup(
    videoOption: FilterOption(
      durationConstraint: DurationConstraint(max: 3.minutes),
    ),
  );

  static AppTheme _appTheme(BuildContext context) => AppTheme(
        focusColor: context.adaptiveColor,
        primaryColor: context.customReversedAdaptiveColor(),
      );

  static TabsTexts _tabsTexts(BuildContext context) => TabsTexts();

  static SliverGridDelegateWithFixedCrossAxisCount _sliverGridDelegate() =>
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 1.7,
        mainAxisSpacing: 1.5,
      );

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
      context.pickBoth(
        source: ImageSource.both,
        multiSelection: multiSelection,
        filterOption: _defaultFilterOption,
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
      context.pickImage(
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
  }) =>
      context.pickVideo(
        source: source,
        filterOption: _defaultFilterOption,
        galleryDisplaySettings: GalleryDisplaySettings(
          showImagePreview: showPreview,
          cropImage: cropImage,
          maximumSelection: maxSelection,
          tabsTexts: _tabsTexts(context),
          appTheme: _appTheme(context),
          callbackFunction: (details) => onMediaPicked.call(context, details),
        ),
      );

  /// Reads image as bytes.
  static Future<Uint8List> imageBytes({required File file}) =>
      compute((file) => file.readAsBytes(), file);
}
