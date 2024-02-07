import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/carousel_indicator_controller.dart';
import 'package:instagram_blocks_ui/src/comments_count.dart';
import 'package:instagram_blocks_ui/src/like_button.dart';
import 'package:instagram_blocks_ui/src/likes_count.dart';
import 'package:instagram_blocks_ui/src/media_carousel_settings.dart';
import 'package:instagram_blocks_ui/src/post_large/post_footer.dart';
import 'package:instagram_blocks_ui/src/post_large/post_header.dart';
import 'package:instagram_blocks_ui/src/post_large/post_media.dart';
import 'package:shared/shared.dart';

class PostLarge extends StatelessWidget {
  const PostLarge({
    required this.block,
    required this.isOwner,
    required this.isLiked,
    required this.likePost,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.isFollowed,
    required this.wasFollowed,
    required this.follow,
    required this.enableFollowButton,
    required this.onCommentsTap,
    required this.onPostShareTap,
    required this.likesText,
    required this.commentsText,
    required this.onPressed,
    required this.withInViewNotifier,
    required this.postOptionsSettings,
    this.sponsoredText,
    this.postAuthorAvatarBuilder,
    this.videoPlayerBuilder,
    this.postIndex,
    this.likesCountBuilder,
    super.key,
  });

  final PostBlock block;

  final bool isOwner;

  final bool wasFollowed;

  final bool isFollowed;

  final VoidCallback follow;

  final bool isLiked;

  final LikeCallback likePost;

  final int likesCount;

  final int commentsCount;

  final LikesText likesText;

  final CommentsText commentsText;

  final String createdAt;

  final bool enableFollowButton;

  final void Function(BlockAction action, String? avatarUrl) onPressed;

  final ValueSetter<bool> onCommentsTap;

  final void Function(String, PostAuthor) onPostShareTap;

  final String? sponsoredText;

  final PostOptionsSettings postOptionsSettings;

  final AvatarBuilder? postAuthorAvatarBuilder;

  final VideoPlayerBuilder? videoPlayerBuilder;

  final int? postIndex;

  final bool withInViewNotifier;

  final Widget? Function(String? name, String? userId, int count)?
      likesCountBuilder;

  @override
  Widget build(BuildContext context) {
    final isSponsored = block is PostSponsoredBlock;
    final indicatorController = CarouselIndicatorController();

    final postMedia = PostMedia(
      isLiked: isLiked,
      media: block.media,
      likePost: likePost,
      onPageChanged: indicatorController.updateCurrentIndex,
      videoPlayerBuilder: videoPlayerBuilder,
      postIndex: postIndex,
      withInViewNotifier: withInViewNotifier,
    );

    Widget postHeader({Color? color}) => PostHeader(
          follow: follow,
          block: block,
          color: color,
          isOwner: isOwner,
          isSponsored: isSponsored,
          isFollowed: isFollowed,
          sponsoredText: sponsoredText,
          wasFollowed: wasFollowed,
          enableFollowButton: enableFollowButton,
          postAuthorAvatarBuilder: postAuthorAvatarBuilder,
          postOptionsSettings: postOptionsSettings,
          onAvatarTap: (avatarUrl) => onPressed(block.action!, avatarUrl),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.isReel)
          Stack(
            children: [
              postMedia,
              postHeader(color: Colors.white),
            ],
          )
        else ...[
          postHeader(),
          postMedia,
        ],
        PostFooter(
          block: block,
          controller: indicatorController,
          imagesUrl: block.mediaUrls,
          isLiked: isLiked,
          likePost: likePost,
          createdAt: createdAt,
          likesCount: likesCount,
          commentsCount: commentsCount,
          onAvatarTap: (avatarUrl) => onPressed(block.action!, avatarUrl),
          onCommentsTap: onCommentsTap,
          onPostShareTap: onPostShareTap,
          likesText: likesText,
          commentsText: commentsText,
          likesCountBuilder: likesCountBuilder,
        ),
      ],
    );
  }
}
