import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/blur_hash_image_placeholder.dart';
import 'package:instagram_blocks_ui/src/safe_set_state_mixin.dart';
import 'package:instagram_blocks_ui/src/smooth_video_progress_indicator.dart';
import 'package:instagram_blocks_ui/src/widgets/popping_icon_overlay.dart';
import 'package:shared/shared.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlay extends StatefulWidget {
  const VideoPlay({
    required this.url,
    required this.play,
    super.key,
    this.blurHash,
    this.withSound = true,
    this.fromMemory = false,
    this.aspectRatio = 4 / 5,
    this.expand = false,
    this.id,
    this.initDelay = Duration.zero,
    this.controller,
    this.onSoundToggled,
    this.withSoundButton = true,
    this.withPlayControll = true,
    this.withVisibilityDetector = true,
    this.withProgressIndicator = false,
    this.loadingBuilder,
    this.stackedWidgets,
    this.videoPlayerOptions,
  });

  final String? id;
  final String url;
  final String? blurHash;
  final double aspectRatio;
  final bool expand;
  final bool fromMemory;
  final bool play;
  final bool withSound;
  final Duration initDelay;
  final VideoPlayerController? controller;
  final ValueSetter<bool>? onSoundToggled;
  final bool withSoundButton;
  final bool withPlayControll;
  final bool withVisibilityDetector;
  final bool withProgressIndicator;
  final WidgetBuilder? loadingBuilder;
  final List<Widget>? stackedWidgets;
  final VideoPlayerOptions? videoPlayerOptions;

  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay>
    with AutomaticKeepAliveClientMixin, SafeSetStateMixin {
  late VideoPlayerController _controller;
  final _isInitialized = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(VideoPlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play) {
      Future<void>.delayed(
        widget.initDelay,
        () => _controller
          ..play()
          ..setLooping(true),
      );
      if (!oldWidget.withSound && widget.withSound) {
        _controller.setVolume(1);
      } else {
        if (_controller.value.volume == 1) {
          if (oldWidget.play == widget.play) return;
          _controller.setVolume(1);
        }
        _controller.setVolume(0);
      }
    } else {
      _controller
        ..pause()
        ..seekTo(Duration.zero);
    }
  }

  Future<void> _initializeController() async {
    _controller = (widget.controller ??
        (widget.fromMemory
            ? VideoPlayerController.asset(
                widget.url,
                videoPlayerOptions: widget.videoPlayerOptions,
              )
            : VideoPlayerController.networkUrl(
                Uri.parse(widget.url),
                videoPlayerOptions: widget.videoPlayerOptions,
              )))
      ..addListener(_controllerListener);
    await Future.wait([
      _controller.initialize(),
      _togglePlayer(),
      _toggleSound(),
    ]);
  }

  Future<void> _togglePlayer() async {
    if (widget.play) {
      await Future.wait([
        _controller.play(),
        _controller.setLooping(true),
      ]);
    } else {
      await Future.wait([
        _controller.pause(),
        _controller.seekTo(Duration.zero),
      ]);
    }
  }

  Future<void> _toggleSound() async {
    if (widget.withSound) {
      await _controller.setVolume(1);
    } else {
      await _controller.setVolume(0);
    }
  }

  void _controllerListener() {
    if (_controller.value.isInitialized) {
      _isInitialized.value = true;
    } else {
      _isInitialized.value = false;
    }
  }

  @override
  void dispose() {
    if (_controller.value.isPlaying) _controller.pause();
    _controller
      ..removeListener(_controllerListener)
      ..dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _isInitialized,
      builder: (context, isInitialized, _) {
        return AnimatedCrossFade(
          duration: 110.ms,
          firstChild: RatioBox(
            aspectRatio: widget.aspectRatio,
            expand: widget.expand,
            child: widget.loadingBuilder?.call(context) ??
                BlurHashImagePlaceholder(blurHash: widget.blurHash),
          ),
          secondChild: ValueListenableBuilder(
            valueListenable: _controller,
            child: Builder(
              builder: (_) {
                late Widget videoPlayer = RatioBox(
                  aspectRatio: widget.aspectRatio,
                  expand: widget.expand,
                  child: VideoPlayer(_controller),
                );
                if (widget.stackedWidgets != null) {
                  videoPlayer = AspectRatio(
                    aspectRatio: widget.aspectRatio,
                    child: Stack(
                      children: [
                        VideoPlayer(_controller),
                        ...widget.stackedWidgets!,
                      ],
                    ),
                  );
                }
                late final withProgessIndicator = Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AspectRatio(
                      aspectRatio: widget.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    SmoothVideoProgressIndicator(controller: _controller),
                  ],
                );
                if (!widget.withVisibilityDetector) {
                  if (widget.withProgressIndicator) {
                    return withProgessIndicator;
                  }
                  return videoPlayer;
                }
                return VisibilityDetector(
                  key: ValueKey(widget.id),
                  onVisibilityChanged: (info) {
                    if (!info.visibleBounds.isEmpty) {
                      if (widget.play) _controller.play();
                    } else {
                      _controller
                        ..pause()
                        ..seekTo(Duration.zero);
                    }
                  },
                  child: widget.withProgressIndicator
                      ? withProgessIndicator
                      : videoPlayer,
                );
              },
            ),
            builder: (context, controller, child) {
              if (!widget.withPlayControll && !widget.withSoundButton) {
                return child!;
              }
              return Stack(
                children: [
                  if (widget.withPlayControll)
                    VideoPlayControll(
                      controller: _controller,
                      controllerValue: controller,
                      child: child!,
                    )
                  else
                    child!,
                  if (widget.withSoundButton)
                    Positioned(
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: SoundToggleButton(controller: _controller),
                    ),
                ],
              );
            },
          ),
          crossFadeState: isInitialized
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        );
      },
    );
  }
}

class RatioBox extends StatelessWidget {
  const RatioBox({
    required this.child,
    required this.expand,
    required this.aspectRatio,
    super.key,
  });

  final Widget child;
  final bool expand;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    if (expand) {
      return ConstrainedBox(
        constraints: BoxConstraints.tightFor(height: context.screenHeight),
        child: child,
      );
    }
    return AspectRatio(aspectRatio: aspectRatio, child: child);
  }
}

class VideoPlayControll extends StatelessWidget {
  const VideoPlayControll({
    required this.child,
    required this.controller,
    required this.controllerValue,
    super.key,
  });

  final Widget child;
  final VideoPlayerController? controller;
  final VideoPlayerValue controllerValue;

  @override
  Widget build(BuildContext context) {
    return PoppingIconAnimationOverlay(
      icon: !controllerValue.isPlaying ? Icons.pause : Icons.play_arrow,
      onTap: () {
        if (controllerValue.isPlaying) {
          controller?.pause();
        } else {
          controller?.play();
        }
      },
      child: child,
    );
  }
}

class SoundToggleButton extends StatelessWidget {
  const SoundToggleButton({
    required this.controller,
    this.onSoundToggled,
    super.key,
  });

  final VideoPlayerController controller;
  final ValueSetter<bool>? onSoundToggled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, controller, snapshot) {
        return Tappable(
          fadeStrength: FadeStrength.medium,
          onTap: () {
            if (controller.volume == 0) {
              this.controller.setVolume(1);
              onSoundToggled?.call(true);
            } else {
              this.controller.setVolume(0);
              onSoundToggled?.call(false);
            }
          },
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: context.customReversedAdaptiveColor(
                light: AppColors.lightDark,
                dark: AppColors.dark,
              ),
              border: Border.all(color: AppColors.borderOutline),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                controller.volume == 1
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: AppColors.white,
                size: AppSize.iconSizeSmall,
              ),
            ),
          ),
        );
      },
    );
  }
}
