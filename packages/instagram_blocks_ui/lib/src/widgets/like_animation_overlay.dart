import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sprung/sprung.dart';

class LikeAnimationOverlay extends StatefulWidget {
  const LikeAnimationOverlay({
    required this.child,
    required this.onTap,
    required this.isLiked,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final Stream<bool> isLiked;

  @override
  State<LikeAnimationOverlay> createState() => _LikeAnimationOverlayState();
}

class _LikeAnimationOverlayState extends State<LikeAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _isAnimating = ValueNotifier(false);
  final _isPostLiked = ValueNotifier(false);

  StreamSubscription<bool>? _isLikedSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    )..addListener(() {
        if (_controller.isAnimating) {
          _isAnimating.value = true;
          return;
        }
        _isAnimating.value = false;
      });

    _isLikedSubscription = widget.isLiked.listen((isLiked) {
      if (isLiked) {
        _isPostLiked.value = true;
        return;
      }
      _isPostLiked.value = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _isLikedSubscription?.cancel();
    _controller.dispose();
  }

  void _handleDoubleTap({required bool isLiked}) {
    if (_controller.isAnimating) {
      _controller
        ..reset()
        ..loop(count: 1);
      _likePost(isLiked: isLiked);
      return;
    }
    _controller.loop(count: 1);
    _likePost(isLiked: isLiked);
  }

  void _likePost({required bool isLiked}) {
    if (isLiked) return;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isPostLiked,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: ValueListenableBuilder(
              valueListenable: _isAnimating,
              builder: (context, isAnimating, child) {
                return _AnimatedIcon(
                  controller: _controller,
                  isAnimating: isAnimating,
                );
              },
            ),
          ),
        ],
      ),
      builder: (context, isLiked, child) {
        return GestureDetector(
          onDoubleTap: () => _handleDoubleTap(isLiked: isLiked),
          child: child,
        );
      },
    );
  }
}

class _AnimatedIcon extends StatelessWidget {
  const _AnimatedIcon({
    required this.controller,
    required this.isAnimating,
  });

  final AnimationController controller;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isAnimating ? 1 : 0,
        duration: const Duration(milliseconds: 50),
        child: const Icon(
          Icons.favorite,
          size: 100,
          color: Colors.white,
        )
            .animate(
              autoPlay: false,
              controller: controller,
            )
            .scaleXY(
              end: 1.3,
              curve: Sprung.custom(damping: 5, stiffness: 85),
              duration: 350.ms,
            )
            .then(delay: 150.ms, curve: Curves.linear)
            .scaleXY(end: 1 / 1.3, duration: 150.ms)
            .fadeOut(duration: 150.ms),
      ),
    );
  }
}
