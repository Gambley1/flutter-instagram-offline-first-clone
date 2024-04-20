// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/video/video.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

enum VideoPlayerType { feed, timeline, reels }

class VideoPlayerInViewNotifierWidget extends StatefulWidget {
  const VideoPlayerInViewNotifierWidget({
    required this.type,
    required this.builder,
    this.id,
    this.checkIsInView,
    this.child,
    super.key,
  });

  final VideoPlayerType type;
  final String? id;
  final bool? checkIsInView;
  final Widget? child;
  final Widget Function(BuildContext context, bool shouldPlay, Widget? child)
      builder;

  @override
  State<VideoPlayerInViewNotifierWidget> createState() =>
      _VideoPlayerNotifierState();
}

class _VideoPlayerNotifierState extends State<VideoPlayerInViewNotifierWidget> {
  late VideoPlayerState _videoPlayerState;
  late ValueNotifier<bool> _shouldPlayType;

  @override
  void initState() {
    super.initState();
    _videoPlayerState = VideoPlayerInheritedWidget.of(context).videoPlayerState;
    _shouldPlayType = switch (widget.type) {
      VideoPlayerType.feed => _videoPlayerState.shouldPlayFeed,
      VideoPlayerType.reels => _videoPlayerState.shouldPlayReels,
      VideoPlayerType.timeline => _videoPlayerState.shouldPlayTimeline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _shouldPlayType,
      child: widget.child,
      builder: (context, shouldPlay, child) {
        if (widget.checkIsInView ?? false) {
          return InViewNotifierWidget(
            id: widget.id!,
            builder: (context, isInView, _) {
              final play = isInView && shouldPlay;
              return widget.builder(context, play, child);
            },
          );
        }
        return widget.builder(context, shouldPlay, child);
      },
    );
  }
}
