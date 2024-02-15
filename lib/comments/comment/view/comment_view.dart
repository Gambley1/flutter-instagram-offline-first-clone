import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comment/comment.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comment/widgets/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comments.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

class CommentView extends StatelessWidget {
  const CommentView({
    required this.comment,
    required this.post,
    this.isReplied = false,
    super.key,
  });

  final Comment comment;
  final PostBlock post;
  final bool isReplied;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return BlocProvider(
      create: (context) => CommentBloc(
        commentId: comment.id,
        postsRepository: context.read<PostsRepository>(),
      )
        ..add(const CommentLikesSubscriptionRequested())
        ..add(CommentIsLikedSubscriptionRequested(user.id))
        ..add(CommentIsLikedByOwnerSubscriptionRequested(post.author.id)),
      child: CommentGroup(
        comment: comment,
        post: post,
        isReplied: isReplied,
      ),
    );
  }
}

class CommentGroup extends StatelessWidget {
  const CommentGroup({
    required this.comment,
    required this.post,
    required this.isReplied,
    super.key,
  });

  final Comment comment;
  final PostBlock post;
  final bool isReplied;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CommentBloc>();
    final user = context.select((AppBloc bloc) => bloc.state.user);

    final isLiked = context.select((CommentBloc bloc) => bloc.state.isLiked);
    final isLikedByOwner =
        context.select((CommentBloc bloc) => bloc.state.isLikedByOwner);
    final likes = context.select((CommentBloc bloc) => bloc.state.likes);

    return Column(
      children: [
        UserComment(
          key: ValueKey(comment.id),
          comment: comment,
          post: post,
          currentUserId: user.id,
          onAvatarTap: () => context.pushNamed(
            'user_profile',
            pathParameters: {'user_id': comment.author.id},
          ),
          avatarBuilder: (context, author, onAvatarTap, radius) =>
              UserStoriesAvatar(
            author: author,
            onAvatarTap: onAvatarTap,
            radius: radius,
            enableUnactiveBorder: false,
            withAdaptiveBorder: false,
          ),
          onReplyButtonTap: (username) => context
              .read<CommentsController>()
              .setReplyingTo(
                commentId: isReplied ? comment.repliedToCommentId! : comment.id,
                username: username,
              ),
          isReplied: isReplied,
          isLiked: isLiked,
          isLikedByOwner: isLikedByOwner,
          onLikeComment: () => bloc.add(CommentLikeRequested(user.id)),
          onCommentDelete: (_) => context.confirmAction(
            title: 'Delete comment',
            content: 'Are you sure you want to delete this comment?',
            yesText: 'Delete',
            fn: () => bloc.add(const CommentDeleteRequested()),
          ),
          likesCount: likes,
          likesText: context.l10n.likesCountTextShort,
          createdAt: comment.createdAt.timeAgoShort(context),
        ),
        if (!isReplied) RepliedComments(comment: comment, post: post),
      ],
    );
  }
}

class RepliedComments extends StatefulWidget {
  const RepliedComments({
    required this.comment,
    required this.post,
    super.key,
  });

  final Comment comment;
  final PostBlock post;

  @override
  State<RepliedComments> createState() => _RepliedCommentsState();
}

class _RepliedCommentsState extends State<RepliedComments> {
  @override
  void initState() {
    super.initState();
    context
        .read<CommentBloc>()
        .add(CommentsRepliedCommentsSubscriptionRequested(widget.comment.id));
  }

  @override
  Widget build(BuildContext context) {
    final repliedComments =
        context.select((CommentBloc bloc) => bloc.state.repliedComments);

    if (repliedComments == null) return const SizedBox.shrink();
    return Column(
      children: repliedComments
          .map(
            (repliedComment) => RepliedComment(
              comment: repliedComment,
              post: widget.post,
            ),
          )
          .toList(),
    );
  }
}
