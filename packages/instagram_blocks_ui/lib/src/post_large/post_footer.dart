import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/carousel_dot_indicator.dart';
import 'package:instagram_blocks_ui/src/carousel_indicator_controller.dart';
import 'package:instagram_blocks_ui/src/comments_count.dart';
import 'package:instagram_blocks_ui/src/like_button.dart';
import 'package:instagram_blocks_ui/src/likes_count.dart';
import 'package:instagram_blocks_ui/src/post_large/post_caption.dart';
import 'package:instagram_blocks_ui/src/post_large/post_header.dart';
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
    required this.onUserProfileAvatarTap,
    required this.onCommentsTap,
    required this.onPostShareTap,
    required this.likesText,
    required this.commentsText,
    required this.createdAt,
    super.key,
  });

  final PostBlock block;
  final CarouselIndicatorController controller;
  final Stream<bool> isLiked;
  final Stream<int> likesCount;
  final Stream<int> commentsCount;
  final LikeCallback likePost;
  final LikesText likesText;
  final CommentsText commentsText;
  // final String sponsoredText;
  final List<String> imagesUrl;
  final OnAvatarTapCallback onUserProfileAvatarTap;
  final ValueSetter<bool> onCommentsTap;
  final void Function(String, PostAuthor) onPostShareTap;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    final isSponsored = block is PostSponsoredBlock;
    final author = block.author;
    final likersInFollowings = block is! PostLargeBlock ||
            (block as PostLargeBlock).likersInFollowings.isEmpty
        ? <User>[]
        : (block as PostLargeBlock)
            .likersInFollowings
            .where((e) => e.avatarUrl != null);
    double avatarStackWidth() {
      if (likersInFollowings.length case 1) {
        return 36;
      }
      if (likersInFollowings.length case 2) {
        return 57;
      }
      return 84;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSponsored)
          SponsoredPostAction(
            imageUrl: block.firstMedia?.url ?? '',
            onTap: () => onUserProfileAvatarTap.call(author.avatarUrl),
          ),
        const AppDivider(padding: 12),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  LikeButton(
                    isLiked: isLiked,
                    like: likePost,
                  ),
                  const SizedBox(width: 14),
                  Tappable(
                    onTap: () => onCommentsTap(true),
                    animationEffect: TappableAnimationEffect.scale,
                    child: Transform.flip(
                      flipX: true,
                      child: const Icon(
                        Icons.chat_bubble_outline_outlined,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Tappable(
                    onTap: () => onPostShareTap(block.id, block.author),
                    animationEffect: TappableAnimationEffect.scale,
                    child: const Icon(
                      Icons.near_me_outlined,
                      size: 30,
                    ),
                  ),
                ],
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
              Tappable(
                animationEffect: TappableAnimationEffect.scale,
                onTap: () {},
                child: const Icon(
                  Icons.bookmark_outline_rounded,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (likersInFollowings.isNotEmpty) ...[
                    AvatarStack(
                      height: 34,
                      width: avatarStackWidth(),
                      borderColor: Colors.black,
                      borderWidth: 2,
                      settings: RestrictedPositions(
                        laying: StackLaying.first,
                      ),
                      avatars: [
                        for (var i = 0; i < likersInFollowings.length; i++)
                          CachedNetworkImageProvider(
                            likersInFollowings.toList()[i].avatarUrl!,
                          ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  RepaintBoundary(
                    child: LikesCount(
                      key: ValueKey(block.id),
                      likesText: likesText,
                      likesCount: likesCount,
                    ),
                  ),
                ],
              ),
              PostCaption(
                username: author.username,
                caption: block.caption,
                onUserProfileAvatarTap: () =>
                    onUserProfileAvatarTap.call(author.avatarUrl),
              ),
              RepaintBoundary(
                child: CommentsCount(
                  count: commentsCount,
                  onTap: () => onCommentsTap(false),
                  commentsText: commentsText,
                ),
              ),
              if (!isSponsored) TimeAgo(createdAt: createdAt),
            ],
          ),
        ),
      ],
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
        provider: NetworkImage(
          widget.imageUrl,
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Visit Instagram Profile',
              style: context.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
