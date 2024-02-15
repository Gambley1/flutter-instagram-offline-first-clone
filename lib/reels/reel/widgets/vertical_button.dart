import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class VerticalButton extends StatelessWidget {
  const VerticalButton({
    required this.onTap,
    this.icon,
    this.child,
    super.key,
    this.color,
    this.size,
  });

  final IconData? icon;
  final Widget? child;
  final Color? color;
  final double? size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      animationEffect: TappableAnimationEffect.scale,
      scaleStrength: ScaleStrength.md,
      onTap: onTap,
      child: child ??
          Icon(
            icon,
            color: color ?? Colors.white,
            size: size,
          ),
    );
  }
}

class VerticalGroup extends StatelessWidget {
  const VerticalGroup({
    required this.onButtonTap,
    this.icon,
    this.child,
    this.size,
    this.iconColor,
    this.withStatistic = true,
    super.key,
    this.onTextTap,
    this.statisticCount = 0,
  });

  final IconData? icon;
  final Widget? child;
  final Color? iconColor;
  final double? size;
  final VoidCallback? onButtonTap;
  final VoidCallback? onTextTap;
  final bool withStatistic;
  final int? statisticCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        VerticalButton(
          icon: icon,
          color: iconColor,
          onTap: onButtonTap,
          size: size,
          child: child,
        ),
        if (withStatistic)
          Tappable(
            onTap: onTextTap,
            animationEffect: TappableAnimationEffect.none,
            child: Text(
              statisticCount!.compactShort(context),
              style: context.bodySmall?.copyWith(
                fontWeight: AppFontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ].insertBetween(const SizedBox(height: AppSpacing.xs)),
    );
  }
}
