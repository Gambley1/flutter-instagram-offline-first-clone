import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';

extension ConfirmDeletion on BuildContext {
  Future<bool> showConfirmDeletion({
    required String title,
    String noText = 'Cancel',
    String yesText = 'Yes',
  }) async {
    final result = await showConfirmationDialog(
      title: title,
      noText: noText,
      yesText: yesText,
    );
    if (result == null) return false;
    return result;
  }
}
