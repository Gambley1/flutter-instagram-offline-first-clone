import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/overlay_drop_down.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryFunctions {
  static FeatureController<T> showDropDown<T>({
    required BuildContext context,
    required DropdownWidgetBuilder<T> builder,
    double? height,
    Duration animationDuration = const Duration(milliseconds: 250),
    required TickerProvider tickerProvider,
  }) {
    final animationController = AnimationController(
      vsync: tickerProvider,
      duration: animationDuration,
    );
    final completer = Completer<T?>();
    var isReply = false;
    OverlayEntry? entry;
    void close(T? value) async {
      if (isReply) {
        return;
      }
      isReply = true;
      animationController.animateTo(0).whenCompleteOrCancel(() async {
        await Future.delayed(const Duration(milliseconds: 16));
        completer.complete(value);
        entry?.remove();
      });
    }

    /// overlay widget
    entry = OverlayEntry(
        builder: (context) => GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => close(null),
              child: OverlayDropDown(
                  height: height!,
                  close: close,
                  animationController: animationController,
                  builder: builder),
            ));
    Overlay.of(context).insert(entry);
    animationController.animateTo(1);
    return FeatureController(
      completer,
      close,
    );
  }

  static onPickMax(GalleryMediaPickerController provider) {
    provider.onPickMax
        .addListener(() => showToast("Already pick ${provider.max} items."));
  }

  static getPermission(setState, GalleryMediaPickerController provider) async {
    /// request for device permission
    var result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
            iosAccessLevel: IosAccessLevel.readWrite));
    if (result.isAuth) {
      /// load "recent" album
      provider.setAssetCount();
      PhotoManager.startChangeNotify();
      PhotoManager.addChangeCallback((value) {
        _refreshPathList(setState, provider);
      });

      if (provider.pathList.isEmpty) {
        _refreshPathList(setState, provider);
      }
    } else {
      /// if result is fail, you can call `PhotoManager.openSetting();`
      /// to open android/ios application's setting to get permission
      PhotoManager.openSetting();
    }
  }

  static _refreshPathList(setState, GalleryMediaPickerController provider) {
    PhotoManager.getAssetPathList(
            type: provider.paramsModel.onlyVideos
                ? RequestType.video
                : provider.paramsModel.onlyImages
                    ? RequestType.image
                    : RequestType.image)
        .then((pathList) {
      /// don't delete setState
      Future.delayed(Duration.zero, () {
        setState(() {
          provider.resetPathList(pathList);
        });
      });
    });
  }

  /// get asset path
  static Future getFile(AssetEntity asset) async {
    var file = await asset.file;
    return file!.path;
  }
}

class FeatureController<T> {
  final Completer<T?> completer;

  final ValueSetter<T?> close;

  FeatureController(this.completer, this.close);

  Future<T?> get closed => completer.future;
}
