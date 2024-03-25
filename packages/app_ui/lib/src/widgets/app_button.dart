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
    this.loading = false,
    this.iconScale = 1.0,
    this.maxLines,
    this.outlined = false,
    this.textStyle,
  });

  /// {@macro app_button}
  const AppButton.auth(
    String text,
    VoidCallback? onPressed, {
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
  const AppButton.inProgress({
    double scale = 0.6,
    Key? key,
    ButtonStyle? style,
  }) : this(
          text: '',
          style: style,
          iconScale: scale,
          loading: true,
          icon: const CircularProgressIndicator(),
          key: key,
        );

  /// Function to be called when the button is pressed.
  final void Function()? onPressed;

  /// The text to be displayed on the button.
  final String? text;

  /// The widget to be displayed inside the button.
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

  /// Optional scaling of icon. Default to 1.0.
  final double? iconScale;

  /// Whether display button as loading with circular progress indicator.
  final bool loading;

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
    final effectiveIcon = icon == null
        ? null
        : Transform.scale(
            scale: iconScale,
            child: icon,
          );
    final effectiveChild = child ?? text;

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
              child: effectiveChild,
            );
          }
        }
        if (effectiveIcon != null) {
          return ElevatedButton.icon(
            onPressed: onPressed,
            icon: effectiveIcon,
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
        if (outlined && effectiveIcon != null) {
          return OutlinedButton.icon(
            style: style,
            onPressed: onPressed,
            icon: effectiveIcon,
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
