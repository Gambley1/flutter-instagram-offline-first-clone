import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template app_divider}
/// The divider widget. Displays a horizontal line.
/// {@endtemplate}
class AppDivider extends StatelessWidget {
  /// {@macro app_divider}
  const AppDivider({
    super.key,
    this.padding,
    this.withText = false,
  });

  /// The optional padding for the divider.
  final double? padding;

  /// Whether the divider should divide with text, e.g `OR`.
  final bool withText;

  @override
  Widget build(BuildContext context) {
    final dividerColor = context.customReversedAdaptiveColor(
      dark: AppColors.emphasizeDarkGrey,
      light: AppColors.brightGrey,
    );

    if (!withText) {
      return Container(
        margin:
            padding != null ? EdgeInsets.symmetric(horizontal: padding!) : null,
        height: 1,
        color: dividerColor,
      );
    }
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.sm,
            ),
            child: const Divider(
              color: Colors.white,
              height: 36,
            ),
          ),
        ),
        Text(
          'OR',
          style: context.titleMedium,
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(
              left: AppSpacing.sm,
              right: AppSpacing.md,
            ),
            child: const Divider(
              color: AppColors.white,
              height: 36,
            ),
          ),
        ),
      ],
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
    this.padding,
    this.withText = false,
  });

  /// The optional padding of the divider.
  final double? padding;

  /// Whether should be displayed with dividing text.
  final bool withText;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AppDivider(padding: padding, withText: withText),
    );
  }
}
