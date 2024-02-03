// ignore_for_file: deprecated_member_use

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';

class FeedAppBar extends StatelessWidget {
  const FeedAppBar({required this.innerBoxIsScrolled, super.key});

  final bool innerBoxIsScrolled;

  @override
  Widget build(BuildContext context) {
    final videoProvider = VideoPlayerProvider.of(context);

    return SliverAppBar(
      centerTitle: false,
      forceElevated: innerBoxIsScrolled,
      title: const AppLogo(height: 50, width: 50),
      actions: [
        Tappable(
          onTap: () {
            videoProvider.pageController
                .animateToPage(2, curve: Curves.easeInOut, duration: 150.ms);
          },
          animationEffect: TappableAnimationEffect.scale,
          child: Assets.icons.chatCircle.svg(
            color: context.adaptiveColor,
            height: AppSize.iconSize,
            width: AppSize.iconSize,
          ),
        ),
      ],
      scrolledUnderElevation: 0,
    );
  }
}
