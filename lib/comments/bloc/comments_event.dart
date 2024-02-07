part of 'comments_bloc.dart';

sealed class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

final class CommentsSubscriptionRequested extends CommentsEvent {
  const CommentsSubscriptionRequested();
}

final class CommentsCommentCreateRequested extends CommentsEvent {
  const CommentsCommentCreateRequested({
    required this.userId,
    required this.content,
    this.repliedToCommentId,
  });

  final String userId;
  final String content;
  final String? repliedToCommentId;

  @override
  List<Object?> get props => [userId, content, repliedToCommentId];
}
