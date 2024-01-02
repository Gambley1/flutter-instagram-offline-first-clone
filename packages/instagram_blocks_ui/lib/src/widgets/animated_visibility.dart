import 'package:flutter/material.dart';

class AnimatedVisibility extends StatelessWidget {
  const AnimatedVisibility({
    required this.child,
    required this.height,
    required this.isVisible,
    required this.curve,
    required this.duration,
    this.maintainSize = true,
    this.maintainState = true,
    this.maintainAnimation = true,
    this.width,
    super.key,
  });

  final Widget child;
  final double height;
  final double? width;
  final bool isVisible;
  final Curve curve;
  final Duration duration;
  final bool maintainSize;
  final bool maintainState;
  final bool maintainAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      height: isVisible ? height : 2,
      width: width,
      child: Visibility(
        visible: isVisible,
        maintainSize: maintainSize,
        maintainState: maintainState,
        maintainAnimation: maintainAnimation,
        child: child,
      ),
    );
  }
}
