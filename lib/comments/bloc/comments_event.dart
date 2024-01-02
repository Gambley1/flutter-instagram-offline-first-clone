part of 'comments_bloc.dart';

sealed class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

final class CommentsPageRequested extends CommentsEvent {
  const CommentsPageRequested({this.page});

  final int? page;

  @override
  List<Object?> get props => [page];
}

final class CommentsRefreshRequested extends CommentsEvent {
  const CommentsRefreshRequested();
}

final class CommentsCommentDeleteRequested extends CommentsEvent {
  const CommentsCommentDeleteRequested({required this.commentId});

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

final class CommentsLikeCommentRequested extends CommentsEvent {
  const CommentsLikeCommentRequested({
    required this.commentId,
    required this.userId,
  });

  final String commentId;
  final String userId;

  @override
  List<Object?> get props => [commentId, userId];
}

final class CommentsPostCommentRequested extends CommentsEvent {
  const CommentsPostCommentRequested({
    required this.postId,
    required this.userId,
    required this.content,
    this.repliedToCommentId,
  });

  final String postId;
  final String userId;
  final String content;
  final String? repliedToCommentId;

  @override
  List<Object?> get props => [postId, userId, content, repliedToCommentId];
}
