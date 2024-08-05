import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template app_divider}
/// The divider widget. Displays a horizontal line.
/// {@endtemplate}
class AppDivider extends StatelessWidget {
  /// {@macro app_divider}
  const AppDivider({
    super.key,
    this.height,
    this.indent,
    this.endIndent,
    this.color,
  });

  /// The divider's height extent.
  ///
  /// The divider itself is always drawn as a horizontal line that is centered
  /// within the height specified by this value.
  ///
  /// If this is null, then the [DividerThemeData.space] is used. If that is
  /// also null, then this defaults to 16.0.
  final double? height;

  /// The amount of empty space to the leading edge of the divider.
  ///
  /// If this is null, then the [DividerThemeData.indent] is used. If that is
  /// also null, then this defaults to 0.0.
  final double? indent;

  /// The amount of empty space to the trailing edge of the divider.
  ///
  /// If this is null, then the [DividerThemeData.endIndent] is used. If that is
  /// also null, then this defaults to 0.0.
  final double? endIndent;

  /// The color to use when painting the line.
  ///
  /// If this is null, then the [DividerThemeData.color] is used. If that is
  /// also null, then [ThemeData.dividerColor] is used.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// const Divider(
  ///   color: Colors.deepOrange,
  /// )
  /// ```
  /// {@end-tool}
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = context.customReversedAdaptiveColor(
      dark: AppColors.emphasizeDarkGrey,
      light: AppColors.brightGrey,
    );

    return Divider(
      height: height,
      indent: indent,
      endIndent: endIndent,
      color: color ?? effectiveColor,
    );
  }
}

/// {@template app_sliver_divider}
/// The sliver divider widget. Displays a horizontal line.
/// {@endtemplate}
class AppSliverDivider extends StatelessWidget {
  /// {@macro app_sliver_divider}
  const AppSliverDivider({
    super.key,
    this.height,
    this.indent,
    this.endIndent,
    this.color,
  });

  /// The divider's height extent.
  ///
  /// The divider itself is always drawn as a horizontal line that is centered
  /// within the height specified by this value.
  ///
  /// If this is null, then the [DividerThemeData.space] is used. If that is
  /// also null, then this defaults to 16.0.
  final double? height;

  /// The amount of empty space to the leading edge of the divider.
  ///
  /// If this is null, then the [DividerThemeData.indent] is used. If that is
  /// also null, then this defaults to 0.0.
  final double? indent;

  /// The amount of empty space to the trailing edge of the divider.
  ///
  /// If this is null, then the [DividerThemeData.endIndent] is used. If that is
  /// also null, then this defaults to 0.0.
  final double? endIndent;

  /// The color to use when painting the line.
  ///
  /// If this is null, then the [DividerThemeData.color] is used. If that is
  /// also null, then [ThemeData.dividerColor] is used.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// const Divider(
  ///   color: Colors.deepOrange,
  /// )
  /// ```
  /// {@end-tool}
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AppDivider(
        color: color,
        endIndent: endIndent,
        indent: indent,
        height: height,
      ),
    );
  }
}
