// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/core/functions.dart';
import 'package:gallery_media_picker/src/data/models/gallery_params_model.dart';
import 'package:gallery_media_picker/src/data/models/picked_asset_model.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/gallery_grid/gallery_grid_view.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/current_path_selector.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryMediaPicker extends StatefulWidget {
  /// params model
  final MediaPickerParamsModel mediaPickerParams;

  /// return all selected paths
  final void Function(List<PickedAssetModel> path) pathList;

  const GalleryMediaPicker({
    super.key,
    required this.mediaPickerParams,
    required this.pathList,
  });

  @override
  State<GalleryMediaPicker> createState() => _GalleryMediaPickerState();
}

class _GalleryMediaPickerState extends State<GalleryMediaPicker> {
  /// create object of PickerDataProvider
  final provider = GalleryMediaPickerController();

  @override
  void initState() {
    provider.paramsModel = widget.mediaPickerParams;
    _getPermission();
    super.initState();
  }

  /// get photo manager permission
  Future<void> _getPermission() async {
    await GalleryFunctions.getPermission(mounted ? setState : null, provider);
    GalleryFunctions.onPickMax(provider);
  }

  @override
  void dispose() {
    provider.onPickMax
        .removeListener(() => GalleryFunctions.onPickMax(provider));
    provider.pickedFile.clear();
    provider.picked.clear();
    provider.pathList.clear();
    PhotoManager.stopChangeNotify();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    provider.max = widget.mediaPickerParams.maxPickImages;
    provider.singlePickMode = widget.mediaPickerParams.singlePick;

    return OKToast(
      child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return false;
          },
          child: Column(
            children: [
              /// album drop down
              Center(
                child: Container(
                  color: widget.mediaPickerParams.appBarColor,
                  alignment: Alignment.bottomLeft,
                  height: widget.mediaPickerParams.appBarHeight,
                  child: SelectedPathDropdownButton(
                    provider: provider,
                    mediaPickerParams: widget.mediaPickerParams,
                  ),
                ),
              ),

              /// grid view
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: provider != null
                      ? AnimatedBuilder(
                          animation: provider.currentAlbumNotifier,
                          builder: (BuildContext context, child) =>
                              GalleryGridView(
                            provider: provider,
                            path: provider.currentAlbum,
                            onAssetItemClick: (asset, index) async {
                              provider.pickEntity(asset);
                              GalleryFunctions.getFile(asset)
                                  .then((value) async {
                                /// add metadata to map list
                                provider.pickPath(PickedAssetModel(
                                  id: asset.id,
                                  path: value,
                                  type: asset.typeInt == 1 ? 'image' : 'video',
                                  videoDuration: asset.videoDuration,
                                  createDateTime: asset.createDateTime,
                                  latitude: asset.latitude,
                                  longitude: asset.longitude,
                                  thumbnail: await asset.thumbnailData,
                                  height: asset.height,
                                  width: asset.width,
                                  orientationHeight: asset.orientatedHeight,
                                  orientationWidth: asset.orientatedWidth,
                                  orientationSize: asset.orientatedSize,
                                  file: await asset.file,
                                  modifiedDateTime: asset.modifiedDateTime,
                                  title: asset.title,
                                  size: asset.size,
                                ));

                                /// send selected media data
                                widget.pathList(provider.pickedFile);
                              });
                            },
                          ),
                        )
                      : Container(),
                ),
              )
            ],
          )),
    );
  }
}
