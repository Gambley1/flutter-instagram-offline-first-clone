import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';

class SwipeableMessage extends StatelessWidget {
  const SwipeableMessage({
    required this.id,
    required this.child,
    required this.onSwiped,
    super.key,
  });

  final String id;
  final Widget child;
  final ValueSetter<SwipeDirection> onSwiped;

  @override
  Widget build(BuildContext context) {
    // The threshold after which the message is considered
    // swiped.
    const threshold = 0.2;

    const swipeDirection = SwipeDirection.endToStart;
    return Swipeable(
      key: ValueKey(id),
      direction: swipeDirection,
      swipeThreshold: threshold,
      onSwiped: onSwiped,
      backgroundBuilder: (context, details) {
        // The alignment of the swipe action.
        const alignment = Alignment.centerRight;

        // The progress of the swipe action.
        final progress = math.min(details.progress, threshold) / threshold;

        // The offset for the reply icon.
        var offset = Offset.lerp(
          const Offset(-24, 0),
          const Offset(12, 0),
          progress,
        )!;

        // If the message is mine, we need to flip the offset.
        // if (isMine) {
        offset = Offset(-offset.dx, -offset.dy);
        // }

        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: offset,
            child: Opacity(
              opacity: progress,
              child: SizedBox.square(
                dimension: 30,
                child: CustomPaint(
                  painter: AnimatedCircleBorderPainter(
                    progress: progress,
                    color: context.customAdaptiveColor(
                      dark: AppColors.brightGrey,
                      light: AppColors.emphasizeDarkGrey,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.reply_rounded,
                      size: ui.lerpDouble(0, 18, progress),
                      color: AppColors.deepBlue,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}
