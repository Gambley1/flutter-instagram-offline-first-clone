import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:lottie/lottie.dart';

class DividerBlock extends StatefulWidget {
  const DividerBlock({
    required this.feedAnimationController,
    super.key,
  });

  final FeedPageController feedAnimationController;

  @override
  State<DividerBlock> createState() => _DividerBlockState();
}

class _DividerBlockState extends State<DividerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppDivider()
            .animate(
          autoPlay: !widget.feedAnimationController.hasPlayedAnimation,
          onInit: (animController) =>
              widget.feedAnimationController.hasPlayedAnimation
                  ? animController.value =
                      widget.feedAnimationController.animationValue
                  : animController.loop(count: 1),
          onComplete: (animController) => widget.feedAnimationController
              .setPlayedAnimation(animController.value),
        )
            .shimmer(
          duration: 1800.ms,
          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
          colors: [
            context.customReversedAdaptiveColor(
              dark: Colors.grey[900],
              light: Colors.grey[300],
            ),
            const Color(0xFF833AB4),
            const Color(0xFFF77737),
            const Color(0xFFE1306C),
            const Color(0xFFC13584),
            const Color(0xFF833AB4),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            children: [
              Column(
                children: [
                  Lottie.asset(
                    'assets/animations/checked-animation.json',
                    fit: BoxFit.cover,
                    frameRate: const FrameRate(64),
                    package: 'app_ui',
                    controller: _controller,
                    onLoaded: (composition) {
                      if (!widget.feedAnimationController.hasPlayedAnimation) {
                        widget.feedAnimationController.setPlayedAnimation(1);
                        _controller
                          ..duration = composition.duration
                          ..forward();
                        return;
                      } else {
                        _controller.value =
                            widget.feedAnimationController.animationValue;
                      }
                    },
                  ),
                  Text(
                    context.l10n.haveSeenAllRecentPosts,
                    style: context.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.haveSeenAllRecentPostsInPast3Days,
                    style: context.bodyLarge
                        ?.copyWith(color: Colors.grey.shade500),
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
        const AppDivider()
            .animate(
          autoPlay: !widget.feedAnimationController.hasPlayedAnimation,
          onInit: (animController) =>
              widget.feedAnimationController.hasPlayedAnimation
                  ? animController.value =
                      widget.feedAnimationController.animationValue
                  : animController.loop(count: 1),
          onComplete: (animController) => widget.feedAnimationController
              .setPlayedAnimation(animController.value),
        )
            .shimmer(
          duration: 2200.ms,
          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
          colors: [
            context.customReversedAdaptiveColor(
              dark: Colors.grey[900],
              light: Colors.grey[300],
            ),
            const Color(0xFF833AB4),
            const Color(0xFFF77737),
            const Color(0xFFE1306C),
            const Color(0xFFC13584),
            const Color(0xFF833AB4),
          ],
        ),
      ],
    );
  }
}
