import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sprung/sprung.dart';

class PoppingIconAnimationOverlay extends StatefulWidget {
  const PoppingIconAnimationOverlay({
    required this.child,
    required this.onTap,
    this.isLiked,
    this.icon,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool? isLiked;
  final IconData? icon;

  @override
  State<PoppingIconAnimationOverlay> createState() =>
      _PoppingIconAnimationOverlayState();
}

class _PoppingIconAnimationOverlayState
    extends State<PoppingIconAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
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

  void _handleTap() {
    if (_controller.isAnimating) {
      _controller
        ..reset()
        ..loop(count: 1);
      widget.onTap();
      return;
    }
    _controller.loop(count: 1);
    widget.onTap();
  }

  void _likePost({required bool isLiked}) {
    if (isLiked) return;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLiked != null ? null : _handleTap,
      onDoubleTap: widget.isLiked == null
          ? null
          : () => _handleDoubleTap(isLiked: widget.isLiked ?? false),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return _AnimatedIcon(
                  controller: _controller,
                  icon: widget.icon,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedIcon extends StatelessWidget {
  const _AnimatedIcon({
    required this.controller,
    this.icon,
  });

  final IconData? icon;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: controller.isAnimating ? 1 : 0,
        duration: 50.ms,
        child: Icon(
          icon ?? Icons.favorite,
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
