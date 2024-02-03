import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class RunningText extends StatelessWidget {
  const RunningText({
    required this.text,
    this.style,
    this.blankSpace = 8,
    this.fadingEdgeStartFraction,
    this.fadingEdgeEndFraction,
    this.velocity = 50,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final double blankSpace;
  final double? fadingEdgeStartFraction;
  final double? fadingEdgeEndFraction;
  final double velocity;

  static const _defaultFadingEdgeStartFraction = .2;
  static const _defaultFadingEdgeEndFraction = .2;

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: text,
      style: style,
      blankSpace: blankSpace,
      velocity: velocity,
      fadingEdgeStartFraction:
          fadingEdgeStartFraction ?? _defaultFadingEdgeStartFraction,
      fadingEdgeEndFraction:
          fadingEdgeEndFraction ?? _defaultFadingEdgeEndFraction,
    );
  }
}
