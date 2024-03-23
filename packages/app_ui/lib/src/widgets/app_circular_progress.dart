import 'package:app_ui/app_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// {@template app_circular_progress}
/// A circular progress indicator that can be used in the app.
/// {@endtemplate}
class AppCircularProgress extends StatelessWidget {
  /// {@macro app_circular_progress}
  const AppCircularProgress(this.color, {super.key});

  /// The color of the circular progress indicator.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: .5,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

/// {@template thine_circular_progress}
/// An Instagram-like circular progress indicator.
/// {@endtemplate}
class ThineCircularProgress extends StatelessWidget {
  /// {@macro thine_circular_progress}
  const ThineCircularProgress({
    super.key,
    this.strokeWidth = 1.0,
    this.backgroundColor,
    this.color,
    this.valueColor,
  });

  /// The color of the circular progress indicator.
  final Color? color;

  /// The color of the background of the circular progress indicator.
  final Color? backgroundColor;

  /// The width of the progress bar line.
  final double strokeWidth;

  /// The color of the progress bar line.
  final Animation<Color?>? valueColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: context.isAndroid
          ? CircularProgressIndicator(
              backgroundColor: backgroundColor,
              valueColor: valueColor,
              strokeWidth: strokeWidth,
              color: color ?? context.theme.focusColor,
            )
          : CupertinoActivityIndicator(
              color: color ?? context.theme.focusColor,
            ),
    );
  }
}
