import 'package:app_ui/app_ui.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/carousel_dot_indicator.dart';
import 'package:instagram_blocks_ui/src/carousel_indicator_controller.dart';
import 'package:instagram_blocks_ui/src/comments_count.dart';
import 'package:instagram_blocks_ui/src/like_button.dart';
import 'package:instagram_blocks_ui/src/likes_count.dart';
import 'package:instagram_blocks_ui/src/post_large/post_caption.dart';
import 'package:instagram_blocks_ui/src/post_large/post_header.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class PostFooter extends StatelessWidget {
  const PostFooter({
    required this.block,
    required this.controller,
    required this.imagesUrl,
    required this.isLiked,
    required this.likePost,
    required this.commentsCount,
    required this.likesCount,
    required this.onAvatarTap,
    required this.onCommentsTap,
    required this.onPostShareTap,
    this.likesCountBuilder,
    super.key,
  });

  final PostBlock block;
  final CarouselIndicatorController controller;
  final bool isLiked;
  final int likesCount;
  final int commentsCount;
  final LikeCallback likePost;
  final List<String> imagesUrl;
  final OnAvatarTapCallback onAvatarTap;
  final ValueSetter<bool> onCommentsTap;
  final void Function(String, PostAuthor) onPostShareTap;
  final Widget? Function(String? name, String? userId, int count)?
      likesCountBuilder;

  @override
  Widget build(BuildContext context) {
    final isSponsored = block is PostSponsoredBlock;
    final author = block.author;
    final likersInFollowings = block is! PostLargeBlock ||
            (block as PostLargeBlock).likersInFollowings.isEmpty
        ? <User>[]
        : (block as PostLargeBlock).likersInFollowings.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isSponsored)
          SponsoredPostAction(
            imageUrl: block.firstMedia?.url ?? '',
            onTap: () => onAvatarTap.call(author.avatarUrl),
          ),
        const AppDivider(padding: AppSpacing.md),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  heightFactor: 1,
                  child: Row(
                    children: <Widget>[
                      LikeButton(
                        isLiked: isLiked,
                        onLikedTap: likePost,
                      ),
                      Tappable(
                        onTap: () => onCommentsTap(true),
                        animationEffect: TappableAnimationEffect.scale,
                        child: Transform.flip(
                          flipX: true,
                          child: Assets.icons.chatCircle.svg(
                            height: AppSize.iconSize,
                            width: AppSize.iconSize,
                            colorFilter: ColorFilter.mode(
                              context.adaptiveColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      Tappable(
                        onTap: () => onPostShareTap(block.id, block.author),
                        animationEffect: TappableAnimationEffect.scale,
                        child: const Icon(
                          Icons.near_me_outlined,
                          size: AppSize.iconSize,
                        ),
                      ),
                    ].insertBetween(const SizedBox(width: AppSpacing.lg)),
                  ),
                ),
              ),
              if (imagesUrl.length > 1)
                ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, index, child) {
                    return CarouselDotIndicator(
                      photoCount: imagesUrl.length,
                      activePhotoIndex: index,
                    );
                  },
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  heightFactor: 1,
                  child: Tappable(
                    animationEffect: TappableAnimationEffect.scale,
                    onTap: () {},
                    child: const Icon(
                      Icons.bookmark_outline_rounded,
                      size: AppSize.iconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (likersInFollowings.isNotEmpty) ...[
                    LikersInFollowings(
                      likersInFollowings: likersInFollowings,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: RepaintBoundary(
                      child: LikesCount(
                        key: ValueKey(block.id),
                        count: likesCount,
                        textBuilder: (count) {
                          final name = likersInFollowings
                              .firstWhere(
                                (user) => user.username != null,
                                orElse: () => User.anonymous,
                              )
                              .username;
                          final userId = likersInFollowings.firstOrNull?.id;
                          if (name == null || name.trim().isEmpty) {
                            return null;
                          }

                          final onTap =
                              userId == null ? null : () => onAvatarTap(userId);

                          return Text.rich(
                            BlockSettings.instance.postTextDelegate.likedByText(
                              count,
                              name,
                              onTap,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.titleMedium,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              PostCaption(
                username: author.username,
                caption: block.caption,
                onUserProfileAvatarTap: () =>
                    onAvatarTap.call(author.avatarUrl),
              ),
              RepaintBoundary(
                child: CommentsCount(
                  count: commentsCount,
                  onTap: () => onCommentsTap.call(false),
                ),
              ),
              if (!isSponsored) TimeAgo(createdAt: block.createdAt),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ],
    );
  }
}

class LikersInFollowings extends StatelessWidget {
  const LikersInFollowings({
    required this.likersInFollowings,
    super.key,
  });

  final List<User> likersInFollowings;

  double get _avatarStackWidth {
    if (likersInFollowings.length case 1) return 28;
    if (likersInFollowings.length case 2) return 44;
    return 60;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: _avatarStackWidth,
      child: WidgetStack(
        positions: RestrictedPositions(laying: StackLaying.first),
        stackedWidgets: [
          for (var i = 0; i < likersInFollowings.length; i++)
            if (likersInFollowings[i].avatarUrl == null)
              CircleAvatar(
                backgroundColor: context.reversedAdaptiveColor,
                child: ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxs),
                    child: CircleAvatar(
                      backgroundColor: AppColors.white,
                      foregroundImage: Assets.images.profilePhoto.provider(),
                    ),
                  ),
                ),
              )
            else
              CachedNetworkImage(
                imageUrl: likersInFollowings[i].avatarUrl!,
                imageBuilder: (context, imageProvider) {
                  return CircleAvatar(
                    backgroundColor: context.reversedAdaptiveColor,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxs),
                        child: CircleAvatar(
                          backgroundImage: imageProvider,
                          backgroundColor: context.theme.colorScheme.background,
                        ),
                      ),
                    ),
                  );
                },
              ),
        ],
        buildInfoWidget: (_) => const SizedBox(),
      ),
    );
  }
}

class SponsoredPostAction extends StatefulWidget {
  const SponsoredPostAction({
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  final String imageUrl;
  final VoidCallback onTap;

  @override
  State<SponsoredPostAction> createState() => _SponsoredPostActionState();
}

class _SponsoredPostActionState extends State<SponsoredPostAction> {
  ColorScheme? _colorScheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ColorScheme.fromImageProvider(
        provider: NetworkImage(widget.imageUrl),
      ).then((value) {
        if (!mounted) return;
        setState(() => _colorScheme = value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      color: Colors.transparent,
      fadeStrength: FadeStrength.small,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: 1700.ms,
        curve: Curves.easeInCubic,
        width: double.infinity,
        color: _colorScheme == null
            ? context.reversedAdaptiveColor
            : (context.isLight
                ? _colorScheme?.primaryContainer
                : _colorScheme?.primary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              BlockSettings
                  .instance.postTextDelegate.visitSponsoredInstagramProfileText,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: context.titleMedium
                  ?.copyWith(fontWeight: AppFontWeight.semiBold),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppSize.iconSizeSmall,
            ),
          ],
        ),
      ),
    );
  }
}
