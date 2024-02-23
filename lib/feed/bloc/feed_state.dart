part of 'feed_bloc.dart';

enum FeedStatus {
  initial,
  loading,
  populated,
  failure,
}

@immutable
class FeedState extends Equatable {
  const FeedState._({
    required this.status,
    required this.feed,
  });

  const FeedState.initial()
      : this._(
          status: FeedStatus.initial,
          feed: const FeedPage.empty(),
        );

  final FeedPage feed;
  final FeedStatus status;

  FeedState loading() => copyWith(status: FeedStatus.loading);
  FeedState populated({FeedPage? feed}) =>
      copyWith(status: FeedStatus.populated, feed: feed);
  FeedState failure() => copyWith(status: FeedStatus.failure);

  FeedState copyWith({
    FeedPage? feed,
    FeedStatus? status,
  }) {
    return FeedState._(
      feed: feed ?? this.feed,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [feed, status];
}
