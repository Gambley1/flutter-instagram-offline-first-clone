// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/post_large/post_header.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared/shared.dart';

typedef CommentsTapCallback = void Function(
  PostBlock block,
  bool showFullSized,
);

class PostsListView extends StatelessWidget {
  const PostsListView({
    required this.blocks,
    required this.isOwner,
    required this.isLiked,
    required this.likesCount,
    required this.likePost,
    required this.follow,
    required this.isFollowed,
    required this.onCommentsTap,
    required this.timeAgo,
    required this.likesText,
    required this.commentsText,
    required this.commentsCountOf,
    required this.onPressed,
    required this.onPostShareTap,
    required this.withInViewNotifier,
    this.withLoading = true,
    this.loading,
    this.withItemController = false,
    this.itemScrollController,
    this.index,
    super.key,
    this.scrollOffsetController,
    this.itemPositionsListener,
    this.scrollOffsetListener,
    this.enableFollowButton = true,
    this.videoPlayerBuilder,
    this.postAuthorAvatarBuilder,
    this.likesCountBuilder,
  });

  final List<PostBlock>? blocks;
  final bool Function(String) isOwner;
  final Stream<bool> Function(String) isLiked;
  final ValueSetter<String> likePost;
  final ValueSetter<String> follow;
  final String Function(DateTime) timeAgo;
  final String Function(int) likesText;
  final String Function(int) commentsText;
  final bool withLoading;
  final bool? loading;
  final bool withItemController;
  final Stream<bool> Function(String) isFollowed;
  final ItemScrollController? itemScrollController;
  final ScrollOffsetController? scrollOffsetController;
  final ItemPositionsListener? itemPositionsListener;
  final ScrollOffsetListener? scrollOffsetListener;
  final int? index;
  final bool enableFollowButton;
  final CommentsTapCallback onCommentsTap;
  final Stream<int> Function(String) likesCount;
  final Stream<int> Function(String) commentsCountOf;
  final void Function(BlockAction action, String? avatarUrl) onPressed;
  final void Function(String, PostAuthor) onPostShareTap;
  final VideoPlayerBuilder? videoPlayerBuilder;
  final AvatarBuilder? postAuthorAvatarBuilder;
  final bool withInViewNotifier;
  final Widget? Function(String? name, String? userId, int count)?
      likesCountBuilder;

  @override
  Widget build(BuildContext context) {
    if (withLoading && (loading ?? false)) return const _LoadingPosts();
    if (blocks == null || (blocks?.isEmpty ?? true)) return const _EmptyPosts();

    if (withItemController) {
      return _PostsItemController(
        blocks: blocks!,
        isLiked: isLiked,
        likesCount: likesCount,
        likePost: likePost,
        index: index!,
        onPressed: onPressed,
        commentsCountOf: commentsCountOf,
        isOwner: isOwner,
        onPostShareTap: onPostShareTap,
        timeAgo: timeAgo,
        itemScrollController: itemScrollController!,
        itemPositionsListener: itemPositionsListener!,
        scrollOffsetController: scrollOffsetController!,
        scrollOffsetListener: scrollOffsetListener!,
        follow: follow,
        isFollowed: isFollowed,
        enableFollowButton: enableFollowButton,
        onCommentsTap: onCommentsTap,
        likesText: likesText,
        commentsText: commentsText,
        videoPlayerBuilder: videoPlayerBuilder,
        postAuthorAvatarBuilder: postAuthorAvatarBuilder,
        withInViewNotifier: withInViewNotifier,
        likesCountBuilder: likesCountBuilder,
      );
    }
    return SliverList.builder(
      itemBuilder: (context, index) {
        final block = blocks![index];
        final id = block.id;
        final author = block.author;
        final createdAt = block.createdAt;
        final isOwner = this.isOwner(block.id);

        return PostLarge(
          block: block,
          isOwner: isOwner,
          key: ValueKey(id),
          isLiked: isLiked(id),
          likePost: () => likePost(id),
          createdAt: timeAgo(createdAt),
          isFollowed: isFollowed(author.id),
          wasFollowed: true,
          follow: () => follow(author.id),
          likesCount: likesCount(id),
          likesText: likesText,
          enableFollowButton: enableFollowButton,
          commentsCount: commentsCountOf(id),
          commentsText: commentsText,
          onCommentsTap: (showFullSized) => onCommentsTap(block, showFullSized),
          onPressed: onPressed,
          onPostShareTap: onPostShareTap,
          videoPlayerBuilder: videoPlayerBuilder,
          postIndex: index,
          postAuthorAvatarBuilder: postAuthorAvatarBuilder,
          withInViewNotifier: withInViewNotifier,
          likesCountBuilder: likesCountBuilder,
        );
      },
      itemCount: blocks!.length,
    );
  }
}

class _PostsItemController extends StatefulWidget {
  const _PostsItemController({
    required this.blocks,
    required this.isOwner,
    required this.isLiked,
    required this.likesCount,
    required this.likePost,
    required this.itemScrollController,
    required this.scrollOffsetController,
    required this.itemPositionsListener,
    required this.scrollOffsetListener,
    required this.index,
    required this.follow,
    required this.isFollowed,
    required this.enableFollowButton,
    required this.onCommentsTap,
    required this.timeAgo,
    required this.likesText,
    required this.commentsText,
    required this.commentsCountOf,
    required this.onPressed,
    required this.onPostShareTap,
    required this.videoPlayerBuilder,
    required this.postAuthorAvatarBuilder,
    required this.withInViewNotifier,
    required this.likesCountBuilder,
  });

  final List<PostBlock> blocks;
  final bool Function(String) isOwner;
  final Stream<bool> Function(String) isLiked;
  final Stream<int> Function(String) likesCount;
  final String Function(int) likesText;
  final ValueSetter<String> likePost;
  final ValueSetter<String> follow;
  final String Function(DateTime) timeAgo;
  final Stream<int> Function(String) commentsCountOf;
  final String Function(int) commentsText;
  final Stream<bool> Function(String) isFollowed;
  final ItemScrollController itemScrollController;
  final ScrollOffsetController scrollOffsetController;
  final ItemPositionsListener itemPositionsListener;
  final ScrollOffsetListener scrollOffsetListener;
  final int index;
  final bool enableFollowButton;
  final CommentsTapCallback onCommentsTap;
  final void Function(BlockAction action, String? avatarUrl) onPressed;
  final void Function(String, PostAuthor) onPostShareTap;
  final VideoPlayerBuilder? videoPlayerBuilder;
  final AvatarBuilder? postAuthorAvatarBuilder;
  final bool withInViewNotifier;
  final Widget? Function(String? name, String? userId, int count)?
      likesCountBuilder;

  @override
  State<_PostsItemController> createState() => _PostsItemControllerState();
}

class _PostsItemControllerState extends State<_PostsItemController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.itemScrollController.jumpTo(index: widget.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: ScrollablePositionedList.builder(
        itemScrollController: widget.itemScrollController,
        itemPositionsListener: widget.itemPositionsListener,
        scrollOffsetController: widget.scrollOffsetController,
        scrollOffsetListener: widget.scrollOffsetListener,
        itemBuilder: (context, index) {
          final block = widget.blocks[index];
          final author = block.author;
          final id = block.id;
          final createdAt = block.createdAt;
          final isOwner = widget.isOwner(author.id);

          return PostLarge(
            block: block,
            isOwner: isOwner,
            key: ValueKey(id),
            isLiked: widget.isLiked(id),
            likePost: () => widget.likePost(id),
            createdAt: widget.timeAgo(createdAt),
            isFollowed: widget.isFollowed(author.id),
            wasFollowed: true,
            follow: () => widget.follow(author.id),
            likesCount: widget.likesCount(id),
            likesText: widget.likesText,
            enableFollowButton: widget.enableFollowButton,
            commentsCount: widget.commentsCountOf(id),
            commentsText: widget.commentsText,
            onCommentsTap: (showFullSized) =>
                widget.onCommentsTap(block, showFullSized),
            onPressed: widget.onPressed,
            onPostShareTap: widget.onPostShareTap,
            videoPlayerBuilder: widget.videoPlayerBuilder,
            postIndex: index,
            postAuthorAvatarBuilder: widget.postAuthorAvatarBuilder,
            withInViewNotifier: widget.withInViewNotifier,
            likesCountBuilder: widget.likesCountBuilder,
          );
        },
        itemCount: widget.blocks.length,
      ),
    );
  }
}

class _EmptyPosts extends StatelessWidget {
  const _EmptyPosts();

  static const _noPostsText = 'No Posts';

  @override
  Widget build(BuildContext context) {
    const noPostsWidget = Center(child: Text(_noPostsText));

    return const SliverFillRemaining(child: noPostsWidget);
  }
}

class _LoadingPosts extends StatelessWidget {
  const _LoadingPosts();

  @override
  Widget build(BuildContext context) {
    const loadingWidget = Center(child: CircularProgressIndicator.adaptive());

    return const SliverFillRemaining(child: loadingWidget);
  }
}
