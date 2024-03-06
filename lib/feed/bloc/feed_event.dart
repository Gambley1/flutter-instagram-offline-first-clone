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

final class FeedPageRequested extends FeedPageBasedEvent {
  const FeedPageRequested({super.page});

  @override
  List<Object?> get props => [page];
}

final class FeedReelsPageRequested extends FeedPageBasedEvent {
  const FeedReelsPageRequested({super.page});

  @override
  List<Object?> get props => [page];
}

final class FeedUpdateRequested extends FeedEvent {
  const FeedUpdateRequested({
    required this.post,
    this.isCreate = false,
    this.isDelete = false,
  });

  final Post post;
  final bool isCreate;
  final bool isDelete;

  @override
  List<Object?> get props => [post, isCreate, isDelete];
}

final class FeedPostCreateRequested extends FeedEvent {
  const FeedPostCreateRequested({
    required this.postId,
    required this.userId,
    required this.caption,
    required this.media,
  });

  final String postId;
  final String userId;
  final String caption;
  final List<Map<String, dynamic>> media;
}

final class FeedRecommenedPostsPageRequested extends FeedPageBasedEvent {
  const FeedRecommenedPostsPageRequested({
    super.page,
  });

  @override
  List<Object?> get props => [page];
}

final class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}
