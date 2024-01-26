// ignore_for_file: avoid_positional_boolean_parameters

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/blur_hash_image_placeholder.dart';
import 'package:instagram_blocks_ui/src/widgets/popping_icon_overlay.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlay extends StatefulWidget {
  const VideoPlay({
    required this.url,
    required this.play,
    super.key,
    this.blurHash = '',
    this.withSound = true,
    this.fromMemory = false,
    this.aspectRatio = 0.65,
    this.id,
    this.onSoundToggled,
  });

  final String? id;
  final String url;
  final String? blurHash;
  final double aspectRatio;
  final bool fromMemory;
  final bool play;
  final bool withSound;
  final void Function(bool enable)? onSoundToggled;

  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  final _isInitialized = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(VideoPlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // _togglePlayer();
    // _toggleSound();
    if (widget.play) {
      _controller?.play();
      _controller?.setLooping(true);
      if (widget.withSound) {
        _controller?.setVolume(1);
      } else {
        if (_controller?.value.volume == 1) {
          if (oldWidget.play == widget.play) return;
          _controller?.setVolume(1);
        }
        _controller?.setVolume(0);
      }
    } else {
      _controller?.pause();
      _controller?.seekTo(Duration.zero);
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _initializeController();
  // }

  Future<void> _initializeController() async {
    if (_controller != null) await _controller?.dispose();
    _controller = widget.fromMemory
        ? VideoPlayerController.asset(widget.url)
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await _controller?.initialize().then((_) {
      if (mounted) setState(() {});
    });
    _controller?.addListener(_controllerListener);
    await _togglePlayer();
    await _toggleSound();
  }

  Future<void> _togglePlayer() async {
    if (widget.play) {
      await _controller?.play();
      await _controller?.setLooping(true);
    } else {
      await _controller?.pause();
      await _controller?.seekTo(Duration.zero);
    }
  }

  Future<void> _toggleSound() async {
    if (widget.withSound) {
      await _controller?.setVolume(1);
    } else {
      await _controller?.setVolume(0);
    }
  }

  void _controllerListener() {
    if (_controller?.value.isInitialized ?? false) {
      _isInitialized.value = true;
    } else {
      _isInitialized.value = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: !isInitialized
              ? BlurHashImagePlaceholder(blurHash: widget.blurHash)
              : ValueListenableBuilder(
                  valueListenable: _controller!,
                  builder: (context, controller, child) {
                    return Stack(
                      children: [
                        PoppingIconAnimationOverlay(
                          icon: !controller.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          onTap: () {
                            if (controller.isPlaying) {
                              _controller?.pause();
                            } else {
                              _controller?.play();
                            }
                          },
                          child: VisibilityDetector(
                            key: ValueKey(widget.id),
                            onVisibilityChanged: (info) {
                              if (!info.visibleBounds.isEmpty) {
                                if (widget.play) _controller?.play();
                              } else {
                                _controller?.pause();
                                _controller?.seekTo(Duration.zero);
                              }
                            },
                            child: AspectRatio(
                              aspectRatio: widget.aspectRatio,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: ValueListenableBuilder(
                            valueListenable: _controller!,
                            builder: (context, controller, snapshot) {
                              return Tappable(
                                fadeStrength: FadeStrength.medium,
                                onTap: () {
                                  if (controller.volume == 0) {
                                    _controller!.setVolume(1);
                                    widget.onSoundToggled?.call(true);
                                  } else {
                                    _controller!.setVolume(0);
                                    widget.onSoundToggled?.call(false);
                                  }
                                },
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(165, 58, 58, 58),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                        45,
                                        250,
                                        250,
                                        250,
                                      ),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      controller.volume == 1
                                          ? Icons.volume_up_rounded
                                          : Icons.volume_off_rounded,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}
