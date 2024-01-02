import 'dart:math';

import 'package:flutter/material.dart';

/// {@template count_number}
/// A widget that animates a count number.
/// {@endtemplate}
class CountNumber extends StatefulWidget {
  /// {@macro count_number}
  const CountNumber({
    required this.count,
    required this.textBuilder,
    super.key,
    this.fontSize = 16,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutQuint,
    this.initialCount = 0,
    this.decimals = 0,
    this.lazyFirstRender = true,
  });

  /// The number to count up to.
  final double count;

  /// The builder for the text.
  final Widget Function(double amount) textBuilder;

  /// The font size of the text.
  final double fontSize;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;

  /// The initial count of the animation.
  final double initialCount;

  /// The number of decimal places to display.
  final int decimals;

  /// Whether to render the first frame lazily.
  final bool lazyFirstRender;

  @override
  State<CountNumber> createState() => _CountNumberState();
}

class _CountNumberState extends State<CountNumber> {
  late double previousAmount = widget.initialCount;
  late bool lazyFirstRender = widget.lazyFirstRender;

  @override
  Widget build(BuildContext context) {
    if (lazyFirstRender && widget.initialCount == widget.count) {
      lazyFirstRender = false;
      return widget.textBuilder(
        double.parse((widget.count).toStringAsFixed(widget.decimals)),
      );
    }

    final Widget builtWidget = TweenAnimationBuilder<int>(
      tween: IntTween(
        begin: (double.parse(previousAmount.toStringAsFixed(widget.decimals)) *
                pow(10, widget.decimals))
            .round(),
        end: (double.parse((widget.count).toStringAsFixed(widget.decimals)) *
                pow(10, widget.decimals))
            .round(),
      ),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, animatedCount, child) {
        return widget.textBuilder(
          animatedCount / pow(10, widget.decimals).toDouble(),
        );
      },
    );

    previousAmount = widget.count;
    return builtWidget;
  }
}
