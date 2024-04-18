import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/blur_hash_image_placeholder.dart';
import 'package:shared/shared.dart';

class InlineVideo extends StatefulWidget {
  const InlineVideo({
    required this.shouldPlay,
    this.videoUrl,
    this.videoFile,
    super.key,
    this.blurHash,
    this.withSound = true,
    this.aspectRatio = _aspectRatio,
    this.shouldExpand = false,
    this.id,
    this.initDelay,
    this.videoPlayerController,
    this.onSoundToggled,
    this.withSoundButton = true,
    this.withPlayerController = true,
    this.withVisibilityDetector = true,
    this.withProgressIndicator = false,
    this.loadingBuilder,
    this.stackedWidget,
    this.videoPlayerOptions,
  });

  static const _aspectRatio = 4 / 5;

  final String? id;
  final String? videoUrl;
  final File? videoFile;
  final String? blurHash;
  final double aspectRatio;
  final bool shouldExpand;
  final bool shouldPlay;
  final bool withSound;
  final Duration? initDelay;
  final VideoPlayerController? videoPlayerController;
  final void Function({required bool enable})? onSoundToggled;
  final bool withSoundButton;
  final bool withPlayerController;
  final bool withVisibilityDetector;
  final bool withProgressIndicator;
  final WidgetBuilder? loadingBuilder;
  final Widget? stackedWidget;
  final VideoPlayerOptions? videoPlayerOptions;

  @override
  State<InlineVideo> createState() => _InlineVideoState();
}

class _InlineVideoState extends State<InlineVideo>
    with AutomaticKeepAliveClientMixin, SafeSetStateMixin {
  late VideoPlayerController? _videoPlayerController;
  late VideoPlayerController _controller;

  bool _playerWasSeen = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(InlineVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controller.value.isPlaying &&
        oldWidget.withSound != widget.withSound) {
      _toggleSound();
    }
    if (oldWidget.shouldPlay == widget.shouldPlay) return;
    _togglePlayer();
  }

  void _initializeController() {
    if (widget.videoPlayerController != null) {
      _controller = widget.videoPlayerController!;
    } else {
      _videoPlayerController = widget.videoFile != null
          ? VideoPlayerController.file(
              widget.videoFile!,
              videoPlayerOptions: widget.videoPlayerOptions,
            )
          : VideoPlayerController.networkUrl(
              Uri.parse(widget.videoUrl!),
              videoPlayerOptions: widget.videoPlayerOptions,
            );
      _controller = _videoPlayerController!;
    }
    _controller.initialize().then((_) async {
      safeSetState(() {});
      _togglePlayer();
      _toggleSound();
    });
  }

  void _togglePlayer() {
    void enablePlayer() {
      _controller
        ..play()
        ..setLooping(true);
    }

    if (widget.shouldPlay) {
      if (widget.initDelay == null) return enablePlayer();
      Future<void>.delayed(widget.initDelay!, enablePlayer);
    } else {
      _controller
        ..pause()
        ..seekTo(Duration.zero);
    }
  }

  void _toggleSound() => _controller.setVolume(widget.withSound ? 1 : 0);

  void _onVideoSeen() {
    if (_playerWasSeen) return;
    safeSetState(() => _playerWasSeen = true);
    if (widget.shouldPlay) _controller.play();
  }

  void _onVideoUnseen() {
    safeSetState(() => _playerWasSeen = false);
    _controller
      ..pause()
      ..seekTo(Duration.zero);
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
    _controller.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final inlineVideo = InlineVideoStack(
      controller: _controller,
      aspectRatio: widget.aspectRatio,
      shouldExpand: widget.shouldExpand,
      withVisibilityDetector: widget.withVisibilityDetector,
      withProgressIndicator: widget.withProgressIndicator,
      onSeen: _onVideoSeen,
      onUnseen: _onVideoUnseen,
      id: widget.id,
      stackedWidget: widget.stackedWidget,
    );

    if (!widget.withPlayerController && !widget.withSoundButton) {
      return inlineVideo;
    }

    return AnimatedCrossFade(
      duration: 110.ms,
      alignment: Alignment.center,
      firstChild: InlineVideoPlaceholder(
        blurHash: widget.blurHash,
        aspectRatio: widget.aspectRatio,
        shouldExpand: widget.shouldExpand,
        loadingBuilder: widget.loadingBuilder,
      ),
      secondChild: Stack(
        children: [
          if (widget.withPlayerController)
            ListenableBuilder(
              listenable: _controller,
              child: inlineVideo,
              builder: (_, child) => InlineVideoPlayerController(
                isPlaying: _controller.value.isPlaying,
                togglePlayer: ({required enable}) =>
                    enable ? _controller.play() : _controller.pause(),
                child: child!,
              ),
            )
          else
            inlineVideo,
          if (widget.withSoundButton)
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (_, __) => ToggleSoundButton(
                  soundEnabled: _controller.value.volume == 1,
                  onSoundToggled: ({required enable}) {
                    widget.onSoundToggled?.call(enable: enable);
                    _controller.setVolume(enable ? 1 : 0);
                  },
                ),
              ),
            ),
        ],
      ),
      crossFadeState: _controller.value.isInitialized
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
    );
  }
}

class InlineVideoPlaceholder extends StatelessWidget {
  const InlineVideoPlaceholder({
    required this.aspectRatio,
    required this.shouldExpand,
    required this.blurHash,
    required this.loadingBuilder,
    super.key,
  });

  final double aspectRatio;
  final bool shouldExpand;
  final String? blurHash;
  final WidgetBuilder? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return RatioBox(
      aspectRatio: aspectRatio,
      expand: shouldExpand,
      child: loadingBuilder?.call(context) ??
          BlurHashImagePlaceholder(blurHash: blurHash),
    );
  }
}

class InlineVideoStack extends StatelessWidget {
  const InlineVideoStack({
    required this.controller,
    required this.aspectRatio,
    required this.shouldExpand,
    required this.withVisibilityDetector,
    required this.withProgressIndicator,
    required this.onSeen,
    required this.onUnseen,
    required this.id,
    required this.stackedWidget,
    super.key,
  });

  final String? id;
  final double aspectRatio;
  final bool shouldExpand;
  final bool withVisibilityDetector;
  final bool withProgressIndicator;
  final VideoPlayerController controller;
  final Widget? stackedWidget;
  final VoidCallback onSeen;
  final VoidCallback onUnseen;

  @override
  Widget build(BuildContext context) {
    late Widget videoPlayer = RatioBox(
      aspectRatio: aspectRatio,
      expand: shouldExpand,
      child: VideoPlayer(controller),
    );
    if (stackedWidget != null) {
      videoPlayer = AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(controller),
            stackedWidget!,
          ],
        ),
      );
    }
    late final videoWithProgressIndicator = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: VideoPlayer(controller),
        ),
        SmoothVideoProgressIndicator(controller: controller),
      ],
    );
    if (!withVisibilityDetector) {
      if (withProgressIndicator) return videoWithProgressIndicator;
      return videoPlayer;
    }
    return Viewable(
      itemKey: ValueKey(id),
      onSeen: onSeen,
      onUnseen: onUnseen,
      child: withProgressIndicator ? videoWithProgressIndicator : videoPlayer,
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

class InlineVideoPlayerController extends StatelessWidget {
  const InlineVideoPlayerController({
    required this.child,
    required this.isPlaying,
    this.togglePlayer,
    super.key,
  });

  final Widget child;
  final bool isPlaying;
  final void Function({required bool enable})? togglePlayer;

  @override
  Widget build(BuildContext context) {
    return PoppingIconAnimationOverlay(
      icon: isPlaying ? Icons.play_arrow : Icons.pause,
      onTap: togglePlayer == null
          ? null
          : () => togglePlayer!.call(enable: !isPlaying),
      child: child,
    );
  }
}

class ToggleSoundButton extends StatelessWidget {
  const ToggleSoundButton({
    required this.soundEnabled,
    this.onSoundToggled,
    super.key,
  });

  final bool soundEnabled;
  final void Function({required bool enable})? onSoundToggled;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      fadeStrength: FadeStrength.medium,
      onTap: () => onSoundToggled?.call(enable: !soundEnabled),
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
            soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: AppColors.white,
            size: AppSize.iconSizeSmall,
          ),
        ),
      ),
    );
  }
}
