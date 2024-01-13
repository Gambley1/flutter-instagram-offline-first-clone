// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedOnTapButton extends StatefulWidget {
  final Widget child;
  final void Function() onTap;
  final Function()? onLongPress;

  const AnimatedOnTapButton({
    Key? key,
    required this.onTap,
    required this.child,
    this.onLongPress,
  }) : super(key: key);

  @override
  _AnimatedOnTapButtonState createState() => _AnimatedOnTapButtonState();
}

class _AnimatedOnTapButtonState extends State<AnimatedOnTapButton>
    with TickerProviderStateMixin {
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
    if (mounted) {
      setState(() {
        squareScaleA = _controllerA.value;
      });
    }
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
          if (mounted) {
            _timer = Timer(const Duration(milliseconds: 100), () {
              _controllerA.fling();
            });
          }
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
