import 'package:flutter/material.dart';

class VideoPlayerProvider {
  VideoPlayerProvider();

  final enablePageView = ValueNotifier(true);
  final shouldPlayFeed = ValueNotifier(true);
  final shouldPlayReels = ValueNotifier(true);
  final shouldPlayTimeline = ValueNotifier(true);
  final withSound = ValueNotifier(false);

  // ignore: use_setters_to_change_properties
  void togglePageView({bool enable = true}) {
    enablePageView.value = enable;
  }

  void playFeed() {
    shouldPlayFeed.value = true;
    shouldPlayReels.value = false;
    shouldPlayTimeline.value = false;
  }

  void playTimeline() {
    shouldPlayFeed.value = false;
    shouldPlayReels.value = false;
    shouldPlayTimeline.value = true;
  }

  void playReels() {
    shouldPlayFeed.value = false;
    shouldPlayReels.value = true;
    shouldPlayTimeline.value = false;
  }

  void stopAll() {
    shouldPlayFeed.value = false;
    shouldPlayReels.value = false;
    shouldPlayTimeline.value = false;
  }
}

class VideoPlayerInheritedWidget extends InheritedWidget {
  const VideoPlayerInheritedWidget({
    required this.videoPlayerProvider,
    required super.child,
    super.key,
  });

  final VideoPlayerProvider videoPlayerProvider;

  @override
  bool updateShouldNotify(VideoPlayerInheritedWidget oldWidget) =>
      videoPlayerProvider != oldWidget.videoPlayerProvider;

  static VideoPlayerInheritedWidget of(BuildContext context) {
    final provider =
        context.getInheritedWidgetOfExactType<VideoPlayerInheritedWidget>();
    assert(provider != null, 'No VideoPlayerProvider found in context!');
    return provider!;
  }

  static VideoPlayerInheritedWidget? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<VideoPlayerInheritedWidget>();
}
