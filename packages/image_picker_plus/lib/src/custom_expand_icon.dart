import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomExpandIcon extends StatelessWidget {
  const CustomExpandIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Transform.rotate(
              angle: 180 * math.pi / 250,
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Transform.rotate(
              angle: 180 * math.pi / 255,
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
