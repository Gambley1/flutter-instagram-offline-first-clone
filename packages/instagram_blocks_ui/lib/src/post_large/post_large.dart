import 'package:flutter/material.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:instagram_blocks_ui/src/block_actiond_callback.dart';
import 'package:instagram_blocks_ui/src/carousel_indicator_controller.dart';
import 'package:instagram_blocks_ui/src/comments_count.dart';
import 'package:instagram_blocks_ui/src/like_button.dart';
import 'package:instagram_blocks_ui/src/likes_count.dart';
import 'package:instagram_blocks_ui/src/post_large/post_footer.dart';
import 'package:instagram_blocks_ui/src/post_large/post_header.dart';
import 'package:instagram_blocks_ui/src/post_large/post_media.dart';

class PostLarge extends StatelessWidget {
  const PostLarge({
    required this.block,
    required this.isOwner,
    required this.hasStories,
    required this.imagesUrl,
    required this.isLiked,
    required this.likePost,
    required this.likesCount,
    required this.commentsCount,
    required this.publishedAt,
    required this.isFollowed,
    required this.wasFollowed,
    required this.follow,
    required this.enableFollowButton,
    required this.onCommentsTap,
    required this.onPostShareTap,
    required this.likesText,
    required this.commentsText,
    required this.onPressed,
    this.sponsoredText,
    super.key,
  });

  final PostBlock block;

  final bool isOwner;

  final bool wasFollowed;

  final Stream<bool> isFollowed;

  final VoidCallback follow;

  final bool hasStories;

  final List<String> imagesUrl;

  final Stream<bool> isLiked;

  final LikeCallback likePost;

  final Stream<int> likesCount;

  final Stream<int> commentsCount;

  final LikesText likesText;

  final CommentsText commentsText;

  final String publishedAt;

  final bool enableFollowButton;

  final BlockActionCallback onPressed;

  final ValueSetter<bool> onCommentsTap;

  final void Function (String, PostAuthor) onPostShareTap;

  final String? sponsoredText;

  @override
  Widget build(BuildContext context) {
    final isSponsored = block is PostSponsoredBlock;
    final indicatorController = CarouselIndicatorController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostHeader(
          author: block.author,
          isSponsored: isSponsored,
          isOwner: isOwner,
          hasStories: hasStories,
          isFollowed: isFollowed,
          follow: follow,
          wasFollowed: wasFollowed,
          avatarOnTap: () => onPressed(block.action!),
          enableFollowButton: enableFollowButton,
          sponsoredText: sponsoredText,
        ),
        PostMedia(
          isLiked: isLiked,
          imagesUrl: imagesUrl,
          likePost: likePost,
          onPageChanged: indicatorController.updateCurrentIndex,
        ),
        PostFooter(
          block: block,
          controller: indicatorController,
          imagesUrl: imagesUrl,
          isLiked: isLiked,
          likePost: likePost,
          publishedAt: publishedAt,
          likesCount: likesCount,
          commentsCount: commentsCount,
          onUserProfileAvatarTap: () => onPressed(block.action!),
          onCommentsTap: onCommentsTap,
          onPostShareTap: onPostShareTap,
          likesText: likesText,
          commentsText: commentsText,
        ),
      ],
    );
  }
}
