// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stories_editor/src/presentation/utils/mixins/safe_set_state_mixin.dart';

class AnimatedOnTapButton extends StatefulWidget {
  final Widget child;
  final void Function() onTap;
  final Function()? onLongPress;

  const AnimatedOnTapButton({
    super.key,
    required this.onTap,
    required this.child,
    this.onLongPress,
  });

  @override
  State<AnimatedOnTapButton> createState() => _AnimatedOnTapButtonState();
}

class _AnimatedOnTapButtonState extends State<AnimatedOnTapButton>
    with TickerProviderStateMixin, SafeSetStateMixin {
  late AnimationController _controllerA;
  double squareScaleA = 1;
  Timer _timer = Timer(const Duration(milliseconds: 300), () {});

  @override
  void initState() {
    _controllerA = AnimationController(
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1,
      duration: const Duration(milliseconds: 10),
    );
    _controllerA.addListener(_controllerAListener);
    super.initState();
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _timer.cancel();
    _controllerA.removeListener(_controllerAListener);
    super.dispose();
  }

  void _controllerAListener() {
    safeSetState(() {
      squareScaleA = _controllerA.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        /// set vibration
        HapticFeedback.lightImpact();
        _controllerA.reverse();
        widget.onTap();
      },
      onTapDown: (dp) {
        _controllerA.reverse();
      },
      onTapUp: (dp) {
        try {
          _timer = Timer(const Duration(milliseconds: 100), () {
            _controllerA.fling();
          });
        } catch (e) {
          debugPrint(e.toString());
        }
      },
      onTapCancel: () {
        _controllerA.fling();
      },
      onLongPress: widget.onLongPress ?? () {},
      child: Transform.scale(
        scale: squareScaleA,
        child: widget.child,
      ),
    );
  }
}
