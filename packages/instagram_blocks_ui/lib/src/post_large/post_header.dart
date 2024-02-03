import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';

typedef OnAvatarTapCallback = void Function(String? avatarUrl);

typedef AvatarBuilder = Widget Function(
  BuildContext context,
  PostAuthor author,
  OnAvatarTapCallback onAvatarTap,
);

class PostHeader extends StatelessWidget {
  const PostHeader({
    required this.author,
    required this.isOwner,
    required this.isFollowed,
    required this.wasFollowed,
    required this.avatarOnTap,
    required this.follow,
    required this.enableFollowButton,
    required this.isSponsored,
    this.sponsoredText,
    this.postAuthorAvatarBuilder,
    super.key,
  });

  final PostAuthor author;

  final bool isOwner;

  final Stream<bool> isFollowed;

  final bool wasFollowed;

  final OnAvatarTapCallback avatarOnTap;

  final VoidCallback follow;

  final bool enableFollowButton;

  final bool isSponsored;

  final String? sponsoredText;

  final AvatarBuilder? postAuthorAvatarBuilder;

  @override
  Widget build(BuildContext context) {
    final username = isSponsored
        ? Row(
            children: [
              Text(
                '${author.username} ',
                style: context.titleMedium,
              ),
              Assets.icons.verifiedUser.svg(
                width: AppSize.iconSizeSmall,
                height: AppSize.iconSizeSmall,
              ),
            ],
          )
        : Text(
            author.username,
            style: context.titleMedium,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tappable(
            onTap: () => avatarOnTap.call(author.avatarUrl),
            animationEffect: TappableAnimationEffect.none,
            child: Row(
              children: [
                postAuthorAvatarBuilder?.call(
                      context,
                      author,
                      avatarOnTap,
                    ) ??
                    UserProfileAvatar(
                      userId: author.id,
                      isLarge: false,
                      avatarUrl: author.avatarUrl,
                      onTap: avatarOnTap,
                      scaleStrength: ScaleStrength.xxs,
                    ),
                const SizedBox(width: AppSpacing.sm),
                if (isSponsored)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      username,
                      Text(
                        sponsoredText!,
                        style: context.bodyMedium,
                      ),
                    ],
                  )
                else
                  username,
              ],
            ),
          ),
          StreamBuilder<bool>(
            stream: isFollowed,
            builder: (context, snapshot) {
              final isSubscribed = snapshot.data;
              if (isSubscribed == null) {
                return const SizedBox.shrink();
              }

              bool showSubscribe() {
                if (isSponsored) return false;
                if (isOwner) return false;
                if (!wasFollowed && isSubscribed) return true;
                if (!wasFollowed && !isSubscribed) return true;
                if (wasFollowed && !isSubscribed) return true;
                if (wasFollowed && isSubscribed) return false;
                return false;
              }

              return Row(
                children: [
                  if (showSubscribe() && enableFollowButton) ...[
                    SubscribeButton(
                      isSubscribed: isSubscribed,
                      wasSubscribed: wasFollowed,
                      subscribe: follow,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  PostOptionsButton(
                    isOwner: isOwner,
                    isSubscribed: isSubscribed,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class PostOptionsButton extends StatelessWidget {
  const PostOptionsButton({
    required this.isOwner,
    super.key,
    this.isSubscribed,
  });

  final bool isOwner;

  final bool? isSubscribed;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {},
      child: const Icon(Icons.more_vert, size: AppSize.iconSizeMedium),
    );
  }
}
