import 'package:flutter/material.dart';

/// {@template app_constrained_scroll_view}
/// The [AppConstrainedScrollView] is a scroll view that has a [Column]
/// as its child and constrains the width and height of the scroll view
/// to the width and height of its parent.
/// {@endtemplate}
class AppConstrainedScrollView extends StatelessWidget {
  /// {@macro app_constrained_scroll_view}
  const AppConstrainedScrollView({
    required this.child,
    this.padding,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.withScrollBar = false,
    super.key,
  });

  /// The widget inside a scroll view.
  final Widget child;

  /// The padding to apply to the scroll view.
  final EdgeInsets? padding;

  /// The [MainAxisAlignment] to apply to the [Column] inside a scroll view.
  final MainAxisAlignment mainAxisAlignment;

  /// Whether to wrap a scroll view with a [Scrollbar].
  final bool withScrollBar;

  Widget _scrollView(BoxConstraints constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            minHeight: constraints.maxHeight,
          ),
          child: IntrinsicHeight(child: child),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return switch (withScrollBar) {
          true => Scrollbar(child: _scrollView(constraints)),
          false => _scrollView(constraints),
        };
      },
    );
  }
}
