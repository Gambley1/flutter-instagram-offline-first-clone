import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/video/video.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

class PostVideoPlayer extends StatelessWidget {
  const PostVideoPlayer({
    required this.videoPlayerType,
    required this.media,
    this.aspectRatio,
    this.isInView,
    super.key,
  });

  final VideoPlayerType videoPlayerType;
  final VideoMedia media;
  final double? aspectRatio;
  final bool? isInView;

  @override
  Widget build(BuildContext context) {
    final videoPlayerState =
        VideoPlayerInheritedWidget.of(context).videoPlayerState;

    return VideoPlayerInViewNotifierWidget(
      type: videoPlayerType,
      builder: (context, shouldPlay, child) {
        final play = shouldPlay && (isInView ?? true);
        return ValueListenableBuilder(
          valueListenable: videoPlayerState.withSound,
          builder: (context, withSound, child) {
            return InlineVideo(
              key: ValueKey(media.id),
              videoSettings: VideoSettings.build(
                videoUrl: media.url,
                shouldPlay: play,
                aspectRatio: aspectRatio,
                blurHash: media.blurHash,
                withSound: withSound,
                videoPlayerOptions: VideoPlayerOptions(
                  mixWithOthers: true,
                ),
                onSoundToggled: ({required enable}) {
                  videoPlayerState.withSound.value = enable;
                },
              ),
            );
          },
        );
      },
    );
  }
}
