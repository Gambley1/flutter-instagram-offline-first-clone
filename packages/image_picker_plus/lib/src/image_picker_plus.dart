import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:image_picker_plus/src/gallery_display.dart';

extension ImagePickerPlus on BuildContext {
  Future<SelectedImagesDetails?> pickImage({
    required ImageSource source,
    GalleryDisplaySettings? galleryDisplaySettings,
    bool multiImages = false,
    FilterOptionGroup? filterOption,
  }) async {
    return _pushToCustomPicker(
      galleryDisplaySettings: galleryDisplaySettings,
      multiSelection: multiImages,
      pickerSource: PickerSource.image,
      source: source,
      filterOption: filterOption,
    );
  }

  Future<SelectedImagesDetails?> pickVideo({
    required ImageSource source,
    GalleryDisplaySettings? galleryDisplaySettings,
    bool multiVideos = false,
    FilterOptionGroup? filterOption,
  }) async {
    return _pushToCustomPicker(
      galleryDisplaySettings: galleryDisplaySettings,
      multiSelection: multiVideos,
      pickerSource: PickerSource.video,
      source: source,
      filterOption: filterOption,
    );
  }

  Future<SelectedImagesDetails?> pickBoth({
    required ImageSource source,
    GalleryDisplaySettings? galleryDisplaySettings,
    bool multiSelection = false,
    FilterOptionGroup? filterOption,
  }) async {
    return _pushToCustomPicker(
      galleryDisplaySettings: galleryDisplaySettings,
      multiSelection: multiSelection,
      pickerSource: PickerSource.both,
      source: source,
      filterOption: filterOption,
    );
  }

  Future<SelectedImagesDetails?> _pushToCustomPicker({
    required ImageSource source,
    GalleryDisplaySettings? galleryDisplaySettings,
    bool multiSelection = false,
    required PickerSource pickerSource,
    FilterOptionGroup? filterOption,
  }) =>
      Navigator.of(this, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CustomImagePicker(
            galleryDisplaySettings: galleryDisplaySettings,
            multiSelection: multiSelection,
            pickerSource: pickerSource,
            source: source,
            filterOption: filterOption,
          ),
          maintainState: false,
        ),
      );
}
