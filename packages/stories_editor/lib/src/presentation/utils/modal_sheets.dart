// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/domain/sevices/save_as_image.dart';
import 'package:stories_editor/src/l10n/stories_editor_localization.dart';
import 'package:stories_editor/src/presentation/utils/Extensions/hexColor.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';

/// custom exit dialog
Future<bool?> exitDialog({
  required BuildContext context,
  required GlobalKey contentKey,
}) =>
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetAnimationDuration: const Duration(milliseconds: 300),
        insetAnimationCurve: Curves.ease,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            padding: const EdgeInsets.only(top: 25, bottom: 5),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: HexColor.fromHex('#262626'),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white10,
                    offset: Offset(0, 1),
                    blurRadius: 4,
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        StoriesEditorLocalization().delegate.discardEditsText,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        StoriesEditorLocalization().delegate.loseAllEditsText,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white54,
                            letterSpacing: 0.1),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                AnimatedOnTapButton(
                  onTap: () async {
                    _resetDefaults(context: context);
                    Navigator.of(context, rootNavigator: true).pop(true);
                  },
                  child: Text(
                    StoriesEditorLocalization().delegate.discardText,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.redAccent.shade200,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 22,
                  child: Divider(
                    color: Colors.white10,
                  ),
                ),
                AnimatedOnTapButton(
                  onTap: () async {
                    final paintingProvider =
                        Provider.of<PaintingNotifier>(context, listen: false);
                    final widgetProvider = Provider.of<DraggableWidgetNotifier>(
                        context,
                        listen: false);
                    if (paintingProvider.lines.isNotEmpty ||
                        widgetProvider.draggableWidget.isNotEmpty) {
                      /// save image
                      var response = await takePicture(
                        contentKey: contentKey,
                        context: context,
                        saveToGallery: true,
                      );
                      if (response) {
                        _dispose(
                          context: context,
                          message: StoriesEditorLocalization()
                              .delegate
                              .successfullySavedText,
                        );
                      } else {
                        _dispose(
                          context: context,
                          message:
                              StoriesEditorLocalization().delegate.errorText,
                        );
                      }
                    } else {
                      _dispose(
                        context: context,
                        message:
                            StoriesEditorLocalization().delegate.draftEmpty,
                      );
                    }
                  },
                  child: Text(
                    StoriesEditorLocalization().delegate.saveDraft,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 22,
                  child: Divider(
                    color: Colors.white10,
                  ),
                ),

                ///cancel
                AnimatedOnTapButton(
                  onTap: () =>
                      Navigator.of(context, rootNavigator: true).pop(false),
                  child: Text(
                    StoriesEditorLocalization().delegate.cancelText,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

void _resetDefaults({required BuildContext context}) {
  final paintingProvider =
      Provider.of<PaintingNotifier>(context, listen: false);
  final widgetProvider =
      Provider.of<DraggableWidgetNotifier>(context, listen: false);
  final controlProvider = Provider.of<ControlNotifier>(context, listen: false);
  final editingProvider =
      Provider.of<TextEditingNotifier>(context, listen: false);
  paintingProvider.lines.clear();
  widgetProvider.draggableWidget.clear();
  widgetProvider.setDefaults();
  paintingProvider.resetDefaults();
  editingProvider.setDefaults();
  controlProvider.mediaPath = '';
}

void _dispose({required BuildContext context, required String message}) {
  _resetDefaults(context: context);
  Fluttertoast.showToast(
      msg: message, backgroundColor: HexColor.fromHex('#262626'));
  Navigator.of(context, rootNavigator: true).pop(true);
}
