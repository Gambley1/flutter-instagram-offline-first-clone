// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/domain/sevices/save_as_image.dart';
import 'package:stories_editor/src/presentation/utils/Extensions/hexColor.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';

/// custom exit dialog
Future<bool> exitDialog({
  required BuildContext context,
  required GlobalKey contentKey,
}) async {
  return (await showDialog(
        context: context,
        barrierColor: Colors.black38,
        barrierDismissible: true,
        builder: (c) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetAnimationDuration: const Duration(milliseconds: 300),
          insetAnimationCurve: Curves.ease,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              padding: const EdgeInsets.only(
                top: 25,
                bottom: 5,
                right: 20,
                left: 20,
              ),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: HexColor.fromHex('#262626'),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.white10,
                        offset: Offset(0, 1),
                        blurRadius: 4),
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Discard Edits?',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "If you go back now, you'll lose all the edits you've made.",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white54,
                        letterSpacing: 0.1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 40,
                  ),

                  /// discard
                  AnimatedOnTapButton(
                    onTap: () async {
                      _resetDefaults(context: context);
                      context.pop(true);
                    },
                    child: Text(
                      'Discard',
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

                  /// save and exit
                  AnimatedOnTapButton(
                    onTap: () async {
                      final paintingProvider =
                          Provider.of<PaintingNotifier>(context, listen: false);
                      final widgetProvider =
                          Provider.of<DraggableWidgetNotifier>(context,
                              listen: false);
                      if (paintingProvider.lines.isNotEmpty ||
                          widgetProvider.draggableWidget.isNotEmpty) {
                        /// save image
                        var response = await takePicture(
                            contentKey: contentKey,
                            context: context,
                            saveToGallery: true);
                        if (response) {
                          _dispose(
                              context: context, message: 'Successfully saved');
                        } else {
                          _dispose(context: context, message: 'Error');
                        }
                      } else {
                        _dispose(context: context, message: 'Draft Empty');
                      }
                    },
                    child: const Text(
                      'Save Draft',
                      style: TextStyle(
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
                    onTap: () {
                      context.pop(false);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
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
      )) ??
      false;
}

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
  context.pop(true);
}
