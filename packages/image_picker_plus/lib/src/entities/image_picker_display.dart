import 'package:flutter/foundation.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:flutter/material.dart';

/// [GalleryDisplaySettings] When you make ImageSource from the camera these settings will be disabled because they belong to the gallery.
class GalleryDisplaySettings {
  final AppTheme? appTheme;
  final TabsTexts? tabsTexts;
  final SliverGridDelegateWithFixedCrossAxisCount gridDelegate;
  final bool showImagePreview;
  final int maximumSelection;
  final AsyncValueSetter<SelectedImagesDetails>? callbackFunction;
  final bool cropImage;
  final bool pickAvatar;

  const GalleryDisplaySettings({
    this.appTheme,
    this.tabsTexts,
    this.callbackFunction,
    this.gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, crossAxisSpacing: 1.7, mainAxisSpacing: 1.5),
    this.showImagePreview = false,
    this.cropImage = false,
    this.maximumSelection = 10,
    this.pickAvatar = false,
  });
}
