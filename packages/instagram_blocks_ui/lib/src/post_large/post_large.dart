// ignore_for_file: avoid_positional_boolean_parameters
// ignore_for_file: use_setters_to_change_properties

import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/post_large/post_footer.dart';
import 'package:instagram_blocks_ui/src/post_large/post_header.dart';
import 'package:instagram_blocks_ui/src/post_large/post_media.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

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

class PostLarge extends StatefulWidget {
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
    this.likersInFollowings,
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
  final List<User>? likersInFollowings;

  @override
  State<PostLarge> createState() => _PostLargeState();
}

class _PostLargeState extends State<PostLarge> {
  late ValueNotifier<int> _indicatorValue;

  @override
  void initState() {
    super.initState();
    _indicatorValue = ValueNotifier(0);
  }

  @override
  void dispose() {
    _indicatorValue.dispose();
    super.dispose();
  }

  void _updateCurrentIndex(int index) => _indicatorValue.value = index;

  @override
  Widget build(BuildContext context) {
    final isSponsored = widget.block is PostSponsoredBlock;

    final postMedia = PostMedia(
      isLiked: widget.isLiked,
      media: widget.block.media,
      likePost: widget.likePost,
      onPageChanged: _updateCurrentIndex,
      videoPlayerBuilder: widget.videoPlayerBuilder,
      postIndex: widget.postIndex,
      withInViewNotifier: widget.withInViewNotifier,
    );

    Widget postHeader({Color? color}) => PostHeader(
          follow: widget.follow,
          block: widget.block,
          color: color,
          isOwner: widget.isOwner,
          isSponsored: isSponsored,
          isFollowed: widget.isFollowed,
          enableFollowButton: widget.enableFollowButton,
          postAuthorAvatarBuilder: widget.postAuthorAvatarBuilder,
          postOptionsSettings: widget.postOptionsSettings,
          onAvatarTap: !widget.block.hasNavigationAction
              ? null
              : (_) => widget.onPressed(widget.block.action),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.block.isReel)
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
          block: widget.block,
          indicatorValue: _indicatorValue,
          mediasUrl: widget.block.mediaUrls,
          isLiked: widget.isLiked,
          likePost: widget.likePost,
          likesCount: widget.likesCount,
          commentsCount: widget.commentsCount,
          onAvatarTap: (_) => widget.onPressed(widget.block.action),
          onUserTap: widget.onUserTap,
          onCommentsTap: widget.onCommentsTap,
          onPostShareTap: widget.onPostShareTap,
          likesCountBuilder: widget.likesCountBuilder,
          likersInFollowings: widget.likersInFollowings,
        ),
      ],
    );
  }
}
