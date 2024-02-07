import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template app_logo}
/// The Application logo that display large Instagram text in a svg format.
/// {@endtemplate}
class AppLogo extends StatelessWidget {
  /// {@macro app_log}
  const AppLogo({
    this.fit = BoxFit.contain,
    super.key,
    this.width,
    this.height,
    this.color,
  });

  /// The fit of the logo.
  final BoxFit fit;

  /// The width of the logo.
  final double? width;

  /// The height of the logo.
  final double? height;

  /// The color of the logo.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Assets.images.instagramTextLogo.svg(
      fit: fit,
      width: width ?? 50,
      height: height ?? 50,
      colorFilter: ColorFilter.mode(
        color ?? context.adaptiveColor,
        BlendMode.srcIn,
      ),
    );
  }
}
