import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({
    required this.isFollowed,
    required this.follow,
    this.isOutlined = false,
    super.key,
  });

  final bool isFollowed;
  final VoidCallback follow;
  final bool isOutlined;

  String? get _followingStatus {
    if (!isFollowed) return BlockSettings().followTextDelegate.followText;
    return BlockSettings().followTextDelegate.followingText;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isOutlined
        ? null
        : context.customReversedAdaptiveColor(
            light: AppColors.brightGrey,
            dark: AppColors.emphasizeDarkGrey,
          );
    Widget button(String data) => Tappable.faded(
          onTap: follow,
          borderRadius: BorderRadius.circular(6),
          backgroundColor: effectiveBackgroundColor,
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

    return switch (_followingStatus) {
      null => const SizedBox.shrink(),
      final String data => Tappable.faded(
          onTap: follow,
          borderRadius: BorderRadius.circular(6),
          backgroundColor: effectiveBackgroundColor,
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
