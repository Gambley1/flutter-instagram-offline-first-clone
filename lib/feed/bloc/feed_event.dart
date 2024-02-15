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
  const FeedPageRequested({
    super.page,
  });

  @override
  List<Object?> get props => [page];
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
