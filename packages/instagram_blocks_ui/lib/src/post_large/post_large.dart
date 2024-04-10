// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/carousel_indicator_controller.dart';
import 'package:instagram_blocks_ui/src/post_large/post_footer.dart';
import 'package:instagram_blocks_ui/src/post_large/post_header.dart';
import 'package:instagram_blocks_ui/src/post_large/post_media.dart';
import 'package:shared/shared.dart';

typedef AvatarBuilder = Widget Function(
  BuildContext context,
  PostAuthor author,
  ValueSetter<String?>? onAvatarTap,
);

typedef LikesCountBuilder = Widget? Function(
  String? name,
  String? userId,
  int count,
);

typedef OnPostShareTap = void Function(String postId, PostAuthor author);

typedef VideoPlayerBuilder = Widget Function(
  BuildContext context,
  VideoMedia media,
  double aspectRatio,
  bool shouldPlay,
);

class PostLarge extends StatelessWidget {
  const PostLarge({
    required this.block,
    required this.isOwner,
    required this.isLiked,
    required this.likePost,
    required this.likesCount,
    required this.commentsCount,
    required this.isFollowed,
    required this.follow,
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
    this.likesCountBuilder,
    super.key,
  });

  final PostBlock block;
  final bool isOwner;
  final bool isFollowed;
  final VoidCallback follow;
  final bool isLiked;
  final VoidCallback likePost;
  final int likesCount;
  final int commentsCount;
  final bool enableFollowButton;
  final ValueSetter<BlockAction?> onPressed;
  final ValueSetter<bool> onCommentsTap;
  final OnPostShareTap onPostShareTap;
  final ValueSetter<String> onUserTap;
  final PostOptionsSettings postOptionsSettings;
  final AvatarBuilder? postAuthorAvatarBuilder;
  final VideoPlayerBuilder? videoPlayerBuilder;
  final int? postIndex;
  final bool withInViewNotifier;
  final LikesCountBuilder? likesCountBuilder;

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
          enableFollowButton: enableFollowButton,
          postAuthorAvatarBuilder: postAuthorAvatarBuilder,
          postOptionsSettings: postOptionsSettings,
          onAvatarTap: !block.hasNavigationAction
              ? null
              : (_) => onPressed(block.action),
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
          likesCount: likesCount,
          commentsCount: commentsCount,
          onAvatarTap: (_) => onPressed(block.action),
          onUserTap: onUserTap,
          onCommentsTap: onCommentsTap,
          onPostShareTap: onPostShareTap,
          likesCountBuilder: likesCountBuilder,
        ),
      ],
    );
  }
}
