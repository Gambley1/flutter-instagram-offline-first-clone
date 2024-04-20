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

final class FeedReelsRefreshRequested extends FeedEvent {
  const FeedReelsRefreshRequested();
}

final class FeedUpdateRequested extends FeedEvent {
  const FeedUpdateRequested({required this.update});

  final PageUpdate update;

  @override
  List<Object?> get props => [update];
}

final class FeedPostCreateRequested extends FeedEvent {
  const FeedPostCreateRequested({
    required this.postId,
    required this.caption,
    required this.media,
  });

  final String postId;
  final String caption;
  final List<Map<String, dynamic>> media;
}

final class FeedRecommendedPostsPageRequested extends FeedPageBasedEvent {
  const FeedRecommendedPostsPageRequested({
    super.page,
  });

  @override
  List<Object?> get props => [page];
}

final class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}
