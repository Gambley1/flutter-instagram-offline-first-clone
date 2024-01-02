import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/comments/bloc/comments_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/comments/controller/comments_controller.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({
    required this.bloc,
    required this.post,
    required this.scrollController,
    required this.scrollableSheetController,
    super.key,
  });

  final FeedBloc bloc;
  final PostBlock post;
  final ScrollController scrollController;
  final DraggableScrollableController scrollableSheetController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CommentsBloc(postsRepository: context.read<PostsRepository>()),
      child: RepositoryProvider.value(
        value: CommentsController(),
        child: CommentsView(
          bloc: bloc,
          post: post,
          scrollController: scrollController,
          scrollableSheetController: scrollableSheetController,
        ),
      ),
    );
  }
}

class CommentsView extends StatelessWidget {
  const CommentsView({
    required this.bloc,
    required this.post,
    required this.scrollController,
    required this.scrollableSheetController,
    super.key,
  });

  final FeedBloc bloc;
  final PostBlock post;
  final ScrollController scrollController;
  final DraggableScrollableController scrollableSheetController;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: CommentTextField(
        postId: post.id,
        controller: scrollableSheetController,
      ),
      body: CommentsListView(
        bloc: bloc,
        post: post,
        scrollController: scrollController,
      ),
    );
  }
}

class TextEmoji extends StatelessWidget {
  const TextEmoji({
    required this.emoji,
    required this.onEmojiTap,
    required this.isFirst,
    required this.isLast,
    super.key,
  });

  final String emoji;
  final bool isFirst;
  final bool isLast;
  final ValueSetter<String> onEmojiTap;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      animationEffect: TappableAnimationEffect.scale,
      onTap: () => onEmojiTap(emoji),
      child: Padding(
        padding: isFirst
            ? const EdgeInsets.only(right: AppSpacing.xlg)
            : isLast
                ? const EdgeInsets.only(right: AppSpacing.xlg)
                : const EdgeInsets.only(
                    right: AppSpacing.xlg,
                  ),
        child: Text(
          emoji,
          style: context.displayMedium,
        ),
      ),
    );
  }
}

class CommentsListView extends StatelessWidget {
  const CommentsListView({
    required this.bloc,
    required this.post,
    required this.scrollController,
    super.key,
  });

  final FeedBloc bloc;
  final PostBlock post;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CommentsBloc>();
    final user = context.select((AppBloc b) => b.state.user);
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 6,
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 162, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade500,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Align(
            child: Text(
              'Comments',
              style: context.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
        StreamBuilder<List<Comment>>(
          stream: bloc.commentsOf(post.id),
          builder: (context, snapshot) {
            final comments = snapshot.data;
            if (!snapshot.hasData || comments == null || comments.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: Text('No comments. Send one!')),
              );
            }
            return SliverList.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Column(
                  children: [
                    UserComment(
                      comment: comment,
                      post: post,
                      currentUserId: user.id,
                      onUserProfileAvatarTap: () {},
                      onReplyButtonTap: (username) =>
                          context.read<CommentsController>().setReplyingTo(
                                commentId: comment.id,
                                username: username,
                              ),
                      isReplied: false,
                      isLiked: bloc.isLiked(
                        commentId: comment.id,
                        userId: user.id,
                      ),
                      isLikedByOwner: bloc.isLikedByOwner(
                        commentId: comment.id,
                        userId: post.author.id,
                      ),
                      onLikeComment: () => bloc.add(
                        CommentsLikeCommentRequested(
                          commentId: comment.id,
                          userId: user.id,
                        ),
                      ),
                      showDeleteCommentConfirm: () =>
                          context.showConfirmationDialog(
                        title: 'Delete this comment?',
                        noText: 'Cancel',
                        yesText: 'Delete',
                      ),
                      onCommentDelete: (id) => bloc
                          .add(CommentsCommentDeleteRequested(commentId: id)),
                      likesCount: bloc.likesOf(comment.id),
                      likesText: (count) =>
                          context.l10n.likesCountTextShort(count),
                      publishedAt: comment.createdAt.timeAgoShort(context),
                    ),
                    RepliedComments(comment: comment, post: post),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class CommentTextField extends StatefulWidget {
  const CommentTextField({
    required this.controller,
    required this.postId,
    super.key,
  });

  final String postId;
  final DraggableScrollableController controller;

  @override
  State<CommentTextField> createState() => _CommentTextFieldState();
}

class _CommentTextFieldState extends State<CommentTextField> {
  late TextEditingController _commentTextController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _commentTextController = TextEditingController();
    context.read<CommentsController>().init(_commentTextController);

    _focusNode = context.read<CommentsController>().commentFocusNode;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (!widget.controller.isAttached) return;
        if (widget.controller.size == 1.0) return;
        widget.controller.animateTo(
          1,
          duration: const Duration(milliseconds: 250),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc b) => b.state.user);
    final commentsController = context.read<CommentsController>();
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: commentsController.isCommentReplyingTo,
            builder: (context, isReplying, child) {
              return Offstage(
                offstage: !isReplying,
                child: ListTile(
                  tileColor: Colors.grey.shade900,
                  title: Text(
                    'Reply to ${commentsController.commentReplyingToUsername}',
                    style: context.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  trailing: Tappable(
                    onTap: () => setState(commentsController.clearReplying),
                    animationEffect: TappableAnimationEffect.none,
                    child: Icon(
                      Icons.cancel,
                      size: 24,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: commentEmojies
                .map(
                  (emoji) => Flexible(
                    child: FittedBox(
                      child: TextEmoji(
                        emoji: emoji,
                        isFirst: emoji == commentEmojies.first,
                        isLast: emoji == commentEmojies.last,
                        onEmojiTap: (emoji) {
                          setState(() {
                            _commentTextController
                              ..text = _commentTextController.text + emoji
                              ..selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: _commentTextController.text.length,
                                ),
                              );
                          });
                        },
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(
              bottom: AppSpacing.lg,
              right: AppSpacing.xs,
            ),
            titleAlignment: ListTileTitleAlignment.titleHeight,
            leading: UserProfileAvatar(
              enableBorder: false,
              isLarge: false,
              onTap: (_) {},
              avatarUrl: user.avatarUrl,
            ),
            subtitle: AppTextField(
              textController: _commentTextController,
              onChanged: (val) {
                setState(() {
                  _commentTextController.text = val;
                });
              },
              hintText: 'Add a comment',
              textInputType: TextInputType.text,
              textInputAction: TextInputAction.newline,
              focusNode: _focusNode,
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            trailing: _commentTextController.text.isEmpty
                ? null
                : Tappable(
                    fadeStrength: FadeStrength.medium,
                    onTap: () {
                      if (_commentTextController.value.text.isEmpty) return;
                      context.read<CommentsBloc>().add(
                            CommentsPostCommentRequested(
                              postId: widget.postId,
                              userId: user.id,
                              content: _commentTextController.value.text,
                              repliedToCommentId:
                                  commentsController.commentReplyingToCommentId,
                            ),
                          );
                      if (commentsController.isReplying) {
                        commentsController.clearReplying();
                      }
                      setState(_commentTextController.clear);
                    },
                    child: Text(
                      'Publish',
                      style: context.bodyLarge
                          ?.copyWith(color: Colors.blue.shade500),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class RepliedComments extends StatelessWidget {
  const RepliedComments({required this.comment, required this.post, super.key});

  final Comment comment;
  final PostBlock post;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc b) => b.state.user);
    final bloc = context.read<CommentsBloc>();
    return StreamBuilder<List<Comment>>(
      stream: bloc.repliedCommentsOf(comment.id),
      builder: (context, snapshot) {
        final comments = snapshot.data;
        if (comments == null) return const SizedBox.shrink();
        return Column(
          children: comments
              .map(
                (c) => UserComment(
                  comment: c,
                  post: post,
                  currentUserId: user.id,
                  onReplyButtonTap: (username) =>
                      context.read<CommentsController>().setReplyingTo(
                            commentId: c.repliedToCommentId!,
                            username: username,
                          ),
                  onUserProfileAvatarTap: () {},
                  isReplied: true,
                  isLiked: bloc.isLiked(
                    commentId: c.id,
                    userId: user.id,
                  ),
                  isLikedByOwner: bloc.isLikedByOwner(
                    commentId: c.id,
                    userId: post.author.id,
                  ),
                  onLikeComment: () => bloc.add(
                    CommentsLikeCommentRequested(
                      commentId: c.id,
                      userId: user.id,
                    ),
                  ),
                  showDeleteCommentConfirm: () =>
                      context.showConfirmationDialog(
                    title: 'Delete this comment?',
                    noText: 'Cancel',
                    yesText: 'Delete',
                  ),
                  onCommentDelete: (id) => bloc.add(
                    CommentsCommentDeleteRequested(
                      commentId: id,
                    ),
                  ),
                  likesCount: bloc.likesOf(c.id),
                  likesText: (count) => context.l10n.likesCountTextShort(count),
                  publishedAt: c.createdAt.timeAgoShort(context),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
