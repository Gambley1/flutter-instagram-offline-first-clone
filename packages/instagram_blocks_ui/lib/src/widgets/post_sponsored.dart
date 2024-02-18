import 'package:flutter/widgets.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/like_button.dart';
import 'package:instagram_blocks_ui/src/post_large/post_header.dart';
import 'package:shared/shared.dart';

class PostSponsored extends StatelessWidget {
  const PostSponsored({
    required this.block,
    required this.isOwner,
    required this.wasFollowed,
    required this.isFollowed,
    required this.follow,
    required this.isLiked,
    required this.likePost,
    required this.likesCount,
    required this.commentsCount,
    required this.enableFollowButton,
    required this.onCommentsTap,
    required this.onPostShareTap,
    required this.onPressed,
    required this.withInViewNotifier,
    required this.postOptionsSettings,
    this.postAuthorAvatarBuilder,
    this.videoPlayerBuilder,
    this.postIndex,
    super.key,
  });

  final PostSponsoredBlock block;
  final bool isOwner;
  final bool wasFollowed;
  final bool isFollowed;
  final VoidCallback follow;
  final bool isLiked;
  final LikeCallback likePost;
  final int likesCount;
  final int commentsCount;
  final bool enableFollowButton;
  final ValueSetter<bool> onCommentsTap;
  final void Function(String, PostAuthor) onPostShareTap;
  final void Function(BlockAction? action, String? avatarUrl) onPressed;
  final PostOptionsSettings postOptionsSettings;
  final AvatarBuilder? postAuthorAvatarBuilder;
  final VideoPlayerBuilder? videoPlayerBuilder;
  final int? postIndex;
  final bool withInViewNotifier;

  @override
  Widget build(BuildContext context) {
    return PostLarge(
      block: block,
      onPressed: onPressed,
      isOwner: isOwner,
      isLiked: isLiked,
      likePost: likePost,
      likesCount: likesCount,
      commentsCount: commentsCount,
      isFollowed: isFollowed,
      wasFollowed: wasFollowed,
      follow: follow,
      enableFollowButton: enableFollowButton,
      onCommentsTap: onCommentsTap,
      onPostShareTap: onPostShareTap,
      postOptionsSettings: postOptionsSettings,
      postAuthorAvatarBuilder: postAuthorAvatarBuilder,
      videoPlayerBuilder: videoPlayerBuilder,
      postIndex: postIndex,
      withInViewNotifier: withInViewNotifier,
    );
  }
}
