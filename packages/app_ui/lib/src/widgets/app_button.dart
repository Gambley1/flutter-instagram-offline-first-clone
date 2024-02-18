import 'package:app_ui/app_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// {@template app_button}
/// A custom button widget.
/// {@endtemplate}
class AppButton extends StatelessWidget {
  /// {@macro app_button}
  const AppButton({
    this.text,
    this.child,
    this.isDialogButton = false,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    super.key,
    this.onPressed,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.style,
    this.height,
    this.width,
    this.icon,
    this.maxLines,
    this.outlined = false,
    this.textStyle,
  });

  /// {@macro app_button}
  const AppButton.auth(
    String text,
    void Function()? onPressed, {
    bool outlined = false,
    Key? key,
    ButtonStyle? style,
  }) : this(
          style: style,
          outlined: outlined,
          text: text,
          onPressed: onPressed,
          key: key,
        );

  /// {@macro app_button}
  const AppButton.outlined({
    required String text,
    VoidCallback? onPressed,
    TextStyle? textStyle,
    Key? key,
    ButtonStyle? style,
  }) : this(
          outlined: true,
          style: style,
          text: text,
          onPressed: onPressed,
          textStyle: textStyle,
          key: key,
        );

  /// {@macro app_button}
  AppButton.inProgress({
    double scale = 0.6,
    Key? key,
    ButtonStyle? style,
  }) : this(
          text: '',
          style: style,
          icon: Transform.scale(
            scale: scale,
            child: const CircularProgressIndicator(),
          ),
          key: key,
        );

  /// Function to be called when the button is pressed.
  final void Function()? onPressed;

  /// The text to be displayed on the button.
  final String? text;

  /// The widget to be displayed inside button.
  final Widget? child;

  /// The width of the button.
  final double? width;

  /// The height of the button.
  final double? height;

  /// The color of the button.
  final Color? color;

  /// The font size of the text on the button.
  final double? fontSize;

  /// The font weight of the text on the button.
  final FontWeight? fontWeight;

  /// The style of the button.
  final ButtonStyle? style;

  /// The style of the text on the button.
  final TextStyle? textStyle;

  /// The maximum amount of lines text can take.
  final int? maxLines;

  /// The icon of the button. If this is not null, the button will be an
  /// [ElevatedButton.icon].
  final Widget? icon;

  /// Whether the button is outlined.
  final bool outlined;

  /// The flag to indicate if the button is used in a dialog.
  final bool isDialogButton;

  /// The flag to indicate if the button is the default action in a dialog.
  final bool isDefaultAction;

  /// The flag to indicate if the button is the destructive action in a dialog.
  final bool isDestructiveAction;

  @override
  Widget build(BuildContext context) {
    final text = _Text(
      text: this.text!,
      style: textStyle,
      maxLines: maxLines,
    );
    final effectiveChild = child ?? text;

    final loading = icon != null;
    final platform = context.theme.platform;
    final isIOS = platform == TargetPlatform.iOS;

    return Builder(
      builder: (_) {
        if (isDialogButton) {
          if (isIOS) {
            return CupertinoDialogAction(
              onPressed: onPressed,
              isDefaultAction: isDefaultAction,
              isDestructiveAction: isDestructiveAction,
              child: effectiveChild,
            );
          } else {
            return TextButton(
              onPressed: onPressed,
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
              ),
              child: effectiveChild,
            );
          }
        }
        if (loading) {
          return ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon!,
            style: style,
            label: effectiveChild,
          );
        }
        if (outlined) {
          return OutlinedButton(
            style: style,
            onPressed: onPressed,
            child: effectiveChild,
          );
        }
        if (outlined && loading) {
          return OutlinedButton.icon(
            style: style,
            onPressed: onPressed,
            icon: icon!,
            label: effectiveChild,
          );
        }
        return ElevatedButton(
          style: style,
          onPressed: onPressed,
          child: effectiveChild,
        );
      },
    );
  }
}

class _Text extends StatelessWidget {
  const _Text({required this.text, this.style, this.maxLines});

  final String text;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: style,
      overflow: TextOverflow.ellipsis,
      child: Text(text, maxLines: maxLines),
    );
  }
}
