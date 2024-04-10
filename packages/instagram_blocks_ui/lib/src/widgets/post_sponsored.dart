import 'package:flutter/widgets.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

class PostSponsored extends StatelessWidget {
  const PostSponsored({
    required this.block,
    required this.isOwner,
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
    required this.onUserTap,
    required this.withInViewNotifier,
    required this.postOptionsSettings,
    this.postAuthorAvatarBuilder,
    this.videoPlayerBuilder,
    this.postIndex,
    super.key,
  });

  final PostSponsoredBlock block;
  final bool isOwner;
  final bool isFollowed;
  final VoidCallback follow;
  final bool isLiked;
  final VoidCallback likePost;
  final int likesCount;
  final int commentsCount;
  final bool enableFollowButton;
  final ValueSetter<bool> onCommentsTap;
  final OnPostShareTap onPostShareTap;
  final ValueSetter<BlockAction?> onPressed;
  final ValueSetter<String> onUserTap;
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
      onUserTap: onUserTap,
      isOwner: isOwner,
      isLiked: isLiked,
      likePost: likePost,
      likesCount: likesCount,
      commentsCount: commentsCount,
      isFollowed: isFollowed,
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
