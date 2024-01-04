import 'package:flutter/widgets.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/block_actiond_callback.dart';
import 'package:instagram_blocks_ui/src/comments_count.dart';
import 'package:instagram_blocks_ui/src/like_button.dart';
import 'package:instagram_blocks_ui/src/likes_count.dart';

class PostSponsored extends StatelessWidget {
  const PostSponsored({
    required this.block,
    required this.isOwner,
    required this.wasFollowed,
    required this.isFollowed,
    required this.follow,
    required this.hasStories,
    required this.imagesUrl,
    required this.isLiked,
    required this.likePost,
    required this.likesCount,
    required this.commentsCount,
    required this.likesText,
    required this.commentsText,
    required this.publishedAt,
    required this.enableFollowButton,
    required this.onCommentsTap,
    required this.onPostShareTap,
    required this.onPressed,
    required this.sponsoredText,
    super.key,
  });

  final PostSponsoredBlock block;

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

  final ValueSetter<bool> onCommentsTap;

  final void Function(String, PostAuthor) onPostShareTap;

  final BlockActionCallback onPressed;

  final String sponsoredText;

  @override
  Widget build(BuildContext context) {
    return PostLarge(
      block: block,
      onPressed: onPressed,
      isOwner: isOwner,
      hasStories: hasStories,
      imagesUrl: imagesUrl,
      isLiked: isLiked,
      likePost: likePost,
      likesCount: likesCount,
      commentsCount: commentsCount,
      publishedAt: publishedAt,
      isFollowed: isFollowed,
      wasFollowed: wasFollowed,
      follow: follow,
      enableFollowButton: enableFollowButton,
      onCommentsTap: onCommentsTap,
      onPostShareTap: onPostShareTap,
      likesText: likesText,
      commentsText: commentsText,
      sponsoredText: sponsoredText,
    );
  }
}
