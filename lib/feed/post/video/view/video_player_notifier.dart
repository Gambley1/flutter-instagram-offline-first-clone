// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/video/video.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

enum VideoPlayerType { feed, timeline, reels }

class VideoPlayerNotifierWidget extends StatefulWidget {
  const VideoPlayerNotifierWidget({
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
  State<VideoPlayerNotifierWidget> createState() => _VideoPlayerNotifierState();
}

class _VideoPlayerNotifierState extends State<VideoPlayerNotifierWidget> {
  late VideoPlayerProvider _videoPlayerProvider;
  late ValueNotifier<bool> _shouldPlayType;

  @override
  void initState() {
    super.initState();
    _videoPlayerProvider =
        VideoPlayerInheritedWidget.of(context).videoPlayerProvider;
    _shouldPlayType = switch (widget.type) {
      VideoPlayerType.feed => _videoPlayerProvider.shouldPlayFeed,
      VideoPlayerType.reels => _videoPlayerProvider.shouldPlayReels,
      VideoPlayerType.timeline => _videoPlayerProvider.shouldPlayTimeline,
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
