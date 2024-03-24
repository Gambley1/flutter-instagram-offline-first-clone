import 'package:app_ui/app_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared/src/config/utilities/extensions/iterable_extension.dart';

/// A useful extension to insert spacers between widgets in a list.
extension ListWidgetSpacer on List<Widget> {
  /// Inserts a spacer between widgets.
  ///
  /// If height is specified the vertical spacer will be used, otherwise
  /// horizontal spacer will be used if width is specified.
  ///
  /// Default is `SizedBox.shrink()`.
  List<Widget> spacerBetween({
    double? height,
    double? width,
  }) {
    return insertBetween(
      height != null
          ? Gap.v(height)
          : width != null
              ? Gap.h(width)
              : const SizedBox.shrink(),
    );
  }
}
