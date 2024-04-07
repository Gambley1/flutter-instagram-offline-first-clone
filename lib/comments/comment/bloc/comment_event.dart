part of 'comment_bloc.dart';

sealed class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

final class CommentLikesSubscriptionRequested extends CommentEvent {
  const CommentLikesSubscriptionRequested();
}

final class CommentIsLikedByOwnerSubscriptionRequested extends CommentEvent {
  const CommentIsLikedByOwnerSubscriptionRequested(this.ownerId);

  final String ownerId;
}

final class CommentIsLikedSubscriptionRequested extends CommentEvent {
  const CommentIsLikedSubscriptionRequested();
}

final class CommentsRepliedCommentsSubscriptionRequested extends CommentEvent {
  const CommentsRepliedCommentsSubscriptionRequested(this.commentId);

  final String commentId;
}

final class CommentLikeRequested extends CommentEvent {
  const CommentLikeRequested();
}

final class CommentDeleteRequested extends CommentEvent {
  const CommentDeleteRequested();
}
