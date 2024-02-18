import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({
    required this.isFollowed,
    required this.wasFollowed,
    required this.follow,
    this.isOutlined = false,
    super.key,
  });

  final bool isFollowed;
  final bool wasFollowed;
  final VoidCallback follow;
  final bool isOutlined;

  String? _followingStatus(BuildContext context) {
    switch ((wasFollowed, isFollowed)) {
      case (true, true):
        return context.l10n.followingUser;
      case (false, false):
        return context.l10n.followUser;
      case (true, false):
        return context.l10n.followUser;
      case _:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isOutlined
        ? null
        : context.customReversedAdaptiveColor(
            light: AppColors.brightGrey,
            dark: AppColors.emphasizeDarkGrey,
          );
    Widget button(String data) => Tappable(
          onTap: follow,
          borderRadius: 6,
          fadeStrength: FadeStrength.medium,
          color: effectiveBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              data,
              style: context.labelLarge
                  ?.apply(color: isOutlined ? AppColors.white : null),
            ),
          ),
        );

    return switch (_followingStatus(context)) {
      null => const SizedBox.shrink(),
      final String data => Tappable(
          onTap: follow,
          borderRadius: 6,
          color: effectiveBackgroundColor,
          child: switch (isOutlined) {
            true => DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.brightGrey),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                child: button(data),
              ),
            false => button(data),
          },
        ),
    };
  }
}
