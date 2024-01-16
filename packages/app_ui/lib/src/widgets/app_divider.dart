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
      dark: Colors.grey[900],
      light: Colors.grey[300],
    );

    if (!withText) {
      // return Divider(indent: 72, height: 0, color: dividerColor);
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
              left: 10,
              right: 6,
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
              left: 6,
              right: 10,
            ),
            child: const Divider(
              color: Colors.white,
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
    final dividerColor = context.customReversedAdaptiveColor(
      dark: Colors.grey[900],
      light: Colors.grey[300],
    );

    if (!withText) {
      return SliverToBoxAdapter(
        child: Container(
          margin: padding != null
              ? EdgeInsets.symmetric(horizontal: padding!)
              : null,
          height: 1,
          color: dividerColor,
        ),
      );
    }
    return SliverToBoxAdapter(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                left: 10,
                right: 6,
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
                left: 6,
                right: 10,
              ),
              child: const Divider(
                color: Colors.white,
                height: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
