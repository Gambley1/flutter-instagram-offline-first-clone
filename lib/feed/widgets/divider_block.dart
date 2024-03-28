import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:lottie/lottie.dart';

class DividerBlock extends StatefulWidget {
  const DividerBlock({
    required this.feedPageController,
    super.key,
  });

  final FeedPageController feedPageController;

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
          autoPlay: !widget.feedPageController.hasPlayedAnimation,
          onInit: (animController) => widget
                  .feedPageController.hasPlayedAnimation
              ? animController.value = widget.feedPageController.animationValue
              : animController.loop(count: 1),
          onComplete: (animController) => widget.feedPageController
              .setPlayedAnimation(animController.value),
        )
            .shimmer(
          duration: 1800.ms,
          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
          colors: [
            context.customReversedAdaptiveColor(
              dark: AppColors.emphasizeDarkGrey,
              light: AppColors.grey,
            ),
            ...AppColors.primaryGradient,
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xlg),
          child: Wrap(
            children: [
              Column(
                children: [
                  Lottie.asset(
                    Assets.animations.checkedAnimation,
                    fit: BoxFit.cover,
                    frameRate: const FrameRate(64),
                    controller: _controller,
                    onLoaded: (composition) {
                      if (!widget.feedPageController.hasPlayedAnimation) {
                        widget.feedPageController.setPlayedAnimation(1);
                        _controller
                          ..duration = composition.duration
                          ..forward();
                        return;
                      } else {
                        _controller.value =
                            widget.feedPageController.animationValue;
                      }
                    },
                  ),
                  Text(
                    context.l10n.haveSeenAllRecentPosts,
                    style: context.titleLarge
                        ?.copyWith(fontWeight: AppFontWeight.medium),
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                  const Gap.v(AppSpacing.sm),
                  Text(
                    context.l10n.haveSeenAllRecentPostsInPast3Days,
                    style: context.bodyLarge?.copyWith(color: AppColors.grey),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ],
          ),
        ),
        const AppDivider()
            .animate(
          autoPlay: !widget.feedPageController.hasPlayedAnimation,
          onInit: (animController) => widget
                  .feedPageController.hasPlayedAnimation
              ? animController.value = widget.feedPageController.animationValue
              : animController.loop(count: 1),
          onComplete: (animController) => widget.feedPageController
              .setPlayedAnimation(animController.value),
        )
            .shimmer(
          duration: 2200.ms,
          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
          colors: [
            context.customReversedAdaptiveColor(
              dark: AppColors.emphasizeDarkGrey,
              light: AppColors.grey,
            ),
            ...AppColors.primaryGradient,
          ],
        ),
      ],
    );
  }
}
