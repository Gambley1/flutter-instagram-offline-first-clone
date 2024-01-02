import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

typedef LikeCallback = void Function();

class LikeButton extends StatelessWidget {
  const LikeButton({
    required this.isLiked,
    required this.like,
    super.key,
    this.tapEffect = TappableAnimationEffect.scale,
    this.scaleStrength = ScaleStrength.xs,
    this.color,
    this.size,
  });

  final Stream<bool> isLiked;

  final LikeCallback like;

  final TappableAnimationEffect tapEffect;

  final Color? color;

  final double? size;

  final ScaleStrength scaleStrength;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: isLiked,
      builder: (context, snapshot) {
        final isLiked = snapshot.data;
        return Tappable(
          color: Colors.transparent,
          animationEffect: tapEffect,
          scaleStrength: scaleStrength,
          onTap: () => isLiked == null ? null : like.call(),
          child: Icon(
            isLiked ?? false ? Icons.favorite : Icons.favorite_outline,
            color: isLiked ?? false ? Colors.red : color,
            size: size ?? 30,
          ),
        );
      },
    );
  }
}
