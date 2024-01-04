part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

sealed class FeedPageBasedEvent extends FeedEvent {
  const FeedPageBasedEvent({this.page});

  final int? page;
}

final class FeedPostCommentsRequested extends FeedPageBasedEvent {
  const FeedPostCommentsRequested({super.page});

  @override
  List<Object?> get props => [page];
}

final class FeedPageRequested extends FeedPageBasedEvent {
  const FeedPageRequested({
    super.page,
  });

  @override
  List<Object?> get props => [page];
}

final class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}

sealed class PostEvent extends FeedEvent {
  const PostEvent(this.postId);

  final String postId;
}

final class FeedLikePostRequested extends PostEvent {
  const FeedLikePostRequested(super.postId);
}

final class FeedPostAuthorFollowRequested extends FeedEvent {
  const FeedPostAuthorFollowRequested(this.author);

  final String author;
}

final class FeedPostIsLikedSubscribeRequested extends FeedEvent {
  const FeedPostIsLikedSubscribeRequested(this.isLiked);

  final Map<String, bool> isLiked;
}

final class FeedPostShareRequested extends FeedEvent {
  const FeedPostShareRequested({
    required this.postId,
    required this.sender,
    required this.message,
    required this.receiver,
    this.postAuthor,
  });

  final String postId;
  final User sender;
  final User receiver;
  final PostAuthor? postAuthor;
  final Message message;
}
