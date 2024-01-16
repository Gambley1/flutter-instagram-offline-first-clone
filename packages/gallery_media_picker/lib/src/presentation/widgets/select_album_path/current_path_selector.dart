import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/data/models/gallery_params_model.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/change_path_widget.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectedPathDropdownButton extends StatelessWidget {
  /// picker provider
  final GalleryMediaPickerController provider;

  /// params model
  final MediaPickerParamsModel mediaPickerParams;

  const SelectedPathDropdownButton(
      {super.key, required this.provider, required this.mediaPickerParams});

  @override
  Widget build(BuildContext context) {
    final arrowDownNotifier = ValueNotifier(false);
    return AnimatedBuilder(
      animation: provider.currentAlbumNotifier,
      builder: (_, __) => Row(
        children: [
          /// show drop down
          Expanded(
            child: DropDown<AssetPathEntity>(
              relativeKey: GlobalKey(),
              child: ((context) =>
                  buildButton(context, arrowDownNotifier))(context),
              dropdownWidgetBuilder: (BuildContext context, close) {
                /// change path button
                return ChangePathWidget(
                  provider: provider,
                  close: close,
                  mediaPickerParams: mediaPickerParams,
                );
              },
              onResult: (AssetPathEntity? value) {
                /// save selected album
                if (value != null) {
                  provider.currentAlbum = value;
                }
              },
              onShow: (value) {
                /// change dropdown arrow state
                arrowDownNotifier.value = value;
              },
            ),
          ),

          /// top custom widget
          Container(
            width: MediaQuery.of(context).size.width / 2,
            alignment: Alignment.bottomLeft,
            child: mediaPickerParams.appBarLeadingWidget ?? Container(),
          )
        ],
      ),
    );
  }

  Widget buildButton(
    BuildContext context,
    ValueNotifier<bool> arrowDownNotifier,
  ) {
    /// local variables
    final decoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(35),
    );

    /// return void container
    if (provider.pathList.isEmpty || provider.currentAlbum == null) {
      return Container();
    }

    /// return decorated container without data
    if (provider.currentAlbum == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: decoration,
      );
    } else {
      /// return list of available albums
      return Container(
        decoration: decoration,
        padding: const EdgeInsets.only(left: 15, bottom: 15),
        alignment: Alignment.bottomLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// current album name
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.28,
              child: Text(
                provider.currentAlbum!.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: mediaPickerParams.appBarTextColor,
                    fontSize: 18,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Spacer(),

            /// animated arrow icon
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: AnimatedBuilder(
                animation: arrowDownNotifier,
                builder: (BuildContext context, child) {
                  return AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: arrowDownNotifier.value ? 0.5 : 0,
                    child: child,
                  );
                },
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: mediaPickerParams.appBarIconColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
