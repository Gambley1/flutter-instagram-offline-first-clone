// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:app_ui/app_ui.dart' hide AppTheme;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:shared/shared.dart';

export 'package:image_picker_plus/src/images_view_page.dart';

class PickImage {
  factory PickImage() => _internal;

  /// {@macro image_picker}
  PickImage._();

  static final PickImage _internal = PickImage._();

  late TabsTexts _tabsTexts;

  // ignore: use_setters_to_change_properties
  void init(TabsTexts tabsTexts) {
    _tabsTexts = tabsTexts;
  }

  static final _defaultFilterOption = FilterOptionGroup(
    videoOption: FilterOption(
      durationConstraint: DurationConstraint(max: 3.minutes),
    ),
  );

  AppTheme _appTheme(BuildContext context) => AppTheme(
        focusColor: context.adaptiveColor,
        primaryColor: context.customReversedAdaptiveColor(),
      );

  SliverGridDelegateWithFixedCrossAxisCount _sliverGridDelegate() =>
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 1.7,
        mainAxisSpacing: 1.5,
      );

  Future<List<AssetEntity>?> pickAssets(
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

  Future<void> pickAssetsFromBoth(
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
          tabsTexts: _tabsTexts,
          appTheme: _appTheme(context),
          callbackFunction: (details) => onMediaPicked.call(context, details),
        ),
      );

  Future<SelectedImagesDetails?> pickImage(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
    int maxSelection = 1,
    bool cropImage = true,
    bool multiImages = false,
    bool showPreview = true,
    bool pickAvatar = false,
  }) =>
      context.pickImage(
        source: source,
        multiImages: multiImages,
        filterOption: _defaultFilterOption,
        galleryDisplaySettings: GalleryDisplaySettings(
          cropImage: cropImage,
          maximumSelection: maxSelection,
          showImagePreview: showPreview,
          tabsTexts: _tabsTexts,
          pickAvatar: pickAvatar,
          appTheme: _appTheme(context),
          gridDelegate: _sliverGridDelegate(),
        ),
      );

  Future<void> pickVideo(
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
          tabsTexts: _tabsTexts,
          appTheme: _appTheme(context),
          callbackFunction: (details) => onMediaPicked.call(context, details),
        ),
      );

  Widget customMediaPicker({
    required BuildContext context,
    required ImageSource source,
    required PickerSource pickerSource,
    required ValueSetter<SelectedImagesDetails> onMediaPicked,
    Key? key,
    bool multiSelection = true,
    FilterOptionGroup? filterOption,
    VoidCallback? onBackButtonTap,
  }) =>
      CustomImagePicker(
        key: key,
        galleryDisplaySettings: GalleryDisplaySettings(
          showImagePreview: true,
          cropImage: true,
          tabsTexts: _tabsTexts,
          appTheme: _appTheme(context),
          callbackFunction: (details) async => onMediaPicked.call(details),
        ),
        multiSelection: multiSelection,
        pickerSource: pickerSource,
        source: source,
        filterOption: _defaultFilterOption,
        onBackButtonTap: onBackButtonTap,
      );

  /// Reads image as bytes.
  Future<Uint8List> imageBytes({required File file}) =>
      compute((file) => file.readAsBytes(), file);
}
