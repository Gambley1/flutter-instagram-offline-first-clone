import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'
    hide NumDurationExtensions;
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/widgets/feed_page_controller.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:lottie/lottie.dart';
import 'package:shared/shared.dart';

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
    with SingleTickerProviderStateMixin, SafeSetStateMixin {
  final _dividerBlockKey = GlobalKey();

  late AnimationController _controller;
  Duration? _animationDuration;

  FeedPageController get feedPageController => widget.feedPageController;
  bool get hasPlayedAnimation => feedPageController.hasPlayedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  void _onLoaded(LottieComposition composition) {
    _animationDuration ??= composition.duration;
    if (hasPlayedAnimation) {
      _controller.value = feedPageController.animationValue;
    }
  }

  void _playAnimation() {
    if (!hasPlayedAnimation) {
      Future<void>.delayed(
        250.ms,
        () => feedPageController.hasPlayedAnimation = true,
      );
      feedPageController.animationValue = 1;
      _controller
        ..duration = _animationDuration
        ..forward();
    }
  }

  void _ensureBlockVisible() {
    if (hasPlayedAnimation) return;
    Scrollable.ensureVisible(
      _dividerBlockKey.currentContext!,
      curve: Easing.legacyDecelerate,
      duration: 450.ms,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: _dividerBlockKey,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Viewable(
          itemKey: const ValueKey('dividerBlock_topAnimatedDivider'),
          onSeen: _ensureBlockVisible,
          child: ListenableBuilder(
            listenable: feedPageController,
            builder: (_, __) {
              return AnimatedShimmerDivider(
                hasPlayedAnimation: hasPlayedAnimation,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xlg),
          child: Wrap(
            children: [
              DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Viewable(
                          itemKey: const ValueKey(
                            'dividerBLock_invisibleCheckIconBox',
                          ),
                          onSeen: _playAnimation,
                          child: const SizedBox(height: 30, width: 30),
                        ),
                        Lottie.asset(
                          Assets.animations.checkedAnimation,
                          fit: BoxFit.cover,
                          frameRate: const FrameRate(64),
                          controller: _controller,
                          onLoaded: _onLoaded,
                        ),
                      ],
                    ),
                    Text(
                      context.l10n.haveSeenAllRecentPosts,
                      style: context.titleLarge
                          ?.copyWith(fontWeight: AppFontWeight.medium),
                    ),
                    const Gap.v(AppSpacing.sm),
                    Text(
                      context.l10n.haveSeenAllRecentPostsInPast3Days,
                      style: context.bodyLarge?.copyWith(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ListenableBuilder(
          listenable: feedPageController,
          builder: (_, __) {
            return AnimatedShimmerDivider(
              hasPlayedAnimation: hasPlayedAnimation,
            );
          },
        ),
      ],
    );
  }
}

class AnimatedShimmerDivider extends StatefulWidget {
  const AnimatedShimmerDivider({
    required this.hasPlayedAnimation,
    super.key,
  });

  final bool hasPlayedAnimation;

  @override
  State<AnimatedShimmerDivider> createState() => _AnimatedShimmerDividerState();
}

class _AnimatedShimmerDividerState extends State<AnimatedShimmerDivider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant AnimatedShimmerDivider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hasPlayedAnimation != widget.hasPlayedAnimation) {
      _controller.loop(count: 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmerBaseColor = context.customReversedAdaptiveColor(
      dark: AppColors.emphasizeDarkGrey,
      light: AppColors.grey,
    );
    return const AppDivider()
        .animate(value: 1, controller: _controller, autoPlay: false)
        .shimmer(
      duration: 2200.ms,
      stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      colors: [shimmerBaseColor, ...AppColors.primaryGradient],
    );
  }
}
