// ignore_for_file: deprecated_member_use

library stories_editor;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/gradient_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/l10n/stories_editor_localization.dart';
import 'package:stories_editor/src/presentation/main_view/main_view.dart';

export 'src/l10n/l10n.dart';
export 'package:stories_editor/stories_editor.dart';

class StoriesEditor extends StatelessWidget {
  /// editor custom font families
  final List<String>? fontFamilyList;

  /// editor custom font families package
  final bool? isCustomFontList;

  /// editor custom color gradients
  final List<List<Color>>? gradientColors;

  /// editor custom logo
  final Widget? middleBottomWidget;

  /// on done
  final Function(String)? onDone;

  /// Function that should be executed when user wants to go back from the page.
  /// Usually pops current page.
  final VoidCallback? onGoBack;

  /// on done button Text
  final Widget? onDoneButtonStyle;

  /// on back pressed
  final Future<bool>? onBackPress;

  /// editor custom color palette list
  final List<Color>? colorList;

  /// editor background color
  final Color? editorBackgroundColor;

  /// gallery thumbnail quality
  final int? galleryThumbnailQuality;

  final StoriesEditorLocalizationDelegate? storiesEditorLocalizationDelegate;

  const StoriesEditor({
    super.key,
    required this.onDone,
    this.middleBottomWidget,
    this.onGoBack,
    this.colorList,
    this.gradientColors,
    this.fontFamilyList,
    this.isCustomFontList,
    this.onBackPress,
    this.onDoneButtonStyle,
    this.editorBackgroundColor,
    this.galleryThumbnailQuality,
    this.storiesEditorLocalizationDelegate,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return false;
      },
      child: ScreenUtilInit(
        designSize: const Size(1080, 1920),
        builder: (_, __) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ControlNotifier()),
            ChangeNotifierProvider(create: (_) => ScrollNotifier()),
            ChangeNotifierProvider(create: (_) => DraggableWidgetNotifier()),
            ChangeNotifierProvider(create: (_) => GradientNotifier()),
            ChangeNotifierProvider(create: (_) => PaintingNotifier()),
            ChangeNotifierProvider(create: (_) => TextEditingNotifier()),
          ],
          child: MainView(
            onDone: onDone,
            fontFamilyList: fontFamilyList,
            isCustomFontList: isCustomFontList,
            middleBottomWidget: middleBottomWidget,
            gradientColors: gradientColors,
            colorList: colorList,
            onDoneButtonStyle: onDoneButtonStyle,
            onBackPress: onBackPress,
            editorBackgroundColor: editorBackgroundColor,
            galleryThumbnailQuality: galleryThumbnailQuality,
            storiesEditorLocalizationDelegate:
                storiesEditorLocalizationDelegate,
          ),
        ),
      ),
    );
  }
}
