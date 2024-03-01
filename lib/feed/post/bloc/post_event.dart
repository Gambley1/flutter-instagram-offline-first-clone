part of 'post_bloc.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

final class PostLikesCountSubscriptionRequested extends PostEvent {
  const PostLikesCountSubscriptionRequested();
}

final class PostCommentsCountSubscriptionRequested extends PostEvent {
  const PostCommentsCountSubscriptionRequested();
}

final class PostIsLikedSubscriptionRequested extends PostEvent {
  const PostIsLikedSubscriptionRequested(this.currentUserId);

  final String currentUserId;
}

final class PostUpdateRequested extends PostEvent {
  const PostUpdateRequested({this.caption, this.onPostUpdated});

  final String? caption;
  final ValueSetter<PostBlock>? onPostUpdated;
}

final class PostAuthoFollowingStatusSubscriptionRequested extends PostEvent {
  const PostAuthoFollowingStatusSubscriptionRequested({
    required this.ownerId,
    required this.currentUserId,
  });

  final String ownerId;
  final String currentUserId;
}

final class PostLikersPageRequested extends PostEvent {
  const PostLikersPageRequested({this.page = 0});

  final int page;
}

final class PostLikeRequested extends PostEvent {
  const PostLikeRequested(this.userId);

  final String userId;
}

final class PostAuthorFollowRequested extends PostEvent {
  const PostAuthorFollowRequested({
    required this.authorId,
    required this.currentUserId,
  });

  final String authorId;
  final String currentUserId;
}

final class PostDeleteRequested extends PostEvent {
  const PostDeleteRequested();
}

final class PostShareRequested extends PostEvent {
  const PostShareRequested({
    required this.sharedPostMessage,
    required this.sender,
    required this.message,
    required this.receiver,
    this.postAuthor,
  });

  final User sender;
  final User receiver;
  final Message sharedPostMessage;
  final Message? message;
  final PostAuthor? postAuthor;
}
