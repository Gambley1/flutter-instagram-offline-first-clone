import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

typedef LikeCallback = void Function();

class LikeButton extends StatelessWidget {
  const LikeButton({
    required this.isLiked,
    required this.onLikedTap,
    super.key,
    this.tapEffect = TappableAnimationEffect.scale,
    this.scaleStrength = ScaleStrength.xs,
    this.color,
    this.size,
  });

  final bool isLiked;

  final LikeCallback onLikedTap;

  final TappableAnimationEffect tapEffect;

  final Color? color;

  final double? size;

  final ScaleStrength scaleStrength;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      color: Colors.transparent,
      animationEffect: tapEffect,
      scaleStrength: scaleStrength,
      onTap: onLikedTap,
      child: Icon(
        isLiked ? Icons.favorite : Icons.favorite_outline,
        color: isLiked ? Colors.red : color,
        size: size ?? AppSize.iconSize,
      ),
    );
  }
}
