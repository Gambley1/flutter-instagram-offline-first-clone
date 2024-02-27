import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:video_player/video_player.dart';

class SmoothVideoProgressIndicator extends StatelessWidget {
  const SmoothVideoProgressIndicator({required this.controller, super.key});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return SmoothVideoProgress(
      controller: controller,
      builder: (context, position, duration, child) {
        final max = duration.inMilliseconds.toDouble();
        final value = position.inMilliseconds.clamp(0, max).toDouble();
        return _VideoProgressIndicator(
          controller,
          max: max,
          value: value,
          allowScrubbing: true,
          padding: const EdgeInsets.only(top: 5),
          colors: const VideoProgressColors(
            playedColor: AppColors.brightGrey,
            backgroundColor: AppColors.dark,
          ),
        );
      },
    );
  }
}

/// A scrubber to control [VideoPlayerController]s
class VideoScrubber extends StatefulWidget {
  /// Create a [VideoScrubber] handler with the given [child].
  ///
  /// [controller] is the [VideoPlayerController] that will be controlled by
  /// this scrubber.
  const VideoScrubber({
    required this.child,
    required this.controller,
    super.key,
  });

  /// The widget that will be displayed inside the gesture detector.
  final Widget child;

  /// The [VideoPlayerController] that will be controlled by this scrubber.
  final VideoPlayerController controller;

  @override
  State<VideoScrubber> createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final box = context.findRenderObject()! as RenderBox;
      final tapPos = box.globalToLocal(globalPosition);
      final relative = tapPos.dx / box.size.width;
      final position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying &&
            controller.value.position != controller.value.duration) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

/// Displays the play/buffering status of the video controlled by [controller].
///
/// If [allowScrubbing] is true, this widget will detect taps and drags and
/// seek the video accordingly.
///
/// [padding] allows to specify some extra padding around the progress indicator
/// that will also detect the gestures.
class _VideoProgressIndicator extends StatefulWidget {
  /// Construct an instance that displays the play/buffering status of the video
  /// controlled by [controller].
  ///
  /// Defaults will be used for everything except [controller] if they're not
  /// provided. [allowScrubbing] defaults to false, and [padding] will default
  /// to `top: 5.0`.
  const _VideoProgressIndicator(
    this.controller, {
    required this.max,
    required this.value,
    required this.allowScrubbing,
    required this.padding,
    this.colors = const VideoProgressColors(),
  });

  final double max;

  final double value;

  /// The [VideoPlayerController] that actually associates a video with this
  /// widget.
  final VideoPlayerController controller;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors colors;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  @override
  State<_VideoProgressIndicator> createState() =>
      _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<_VideoProgressIndicator>
    with SingleTickerProviderStateMixin {
  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.isInitialized) {
      final value = widget.value / widget.max;

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          LinearProgressIndicator(
            value: widget.max,
            valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
            backgroundColor: colors.backgroundColor,
          ),
          LinearProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return VideoScrubber(
        controller: controller,
        child: paddedProgressIndicator,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}
