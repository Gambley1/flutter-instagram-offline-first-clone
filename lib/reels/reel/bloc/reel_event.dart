part of 'reel_bloc.dart';

sealed class ReelEvent extends Equatable {
  const ReelEvent();

  @override
  List<Object> get props => [];
}

final class ReelLikesCountSubscriptionRequested extends ReelEvent {
  const ReelLikesCountSubscriptionRequested();
}

final class ReelCommentsCountSubscriptionRequested extends ReelEvent {
  const ReelCommentsCountSubscriptionRequested();
}

final class ReelIsLikedSubscriptionRequested extends ReelEvent {
  const ReelIsLikedSubscriptionRequested(this.currentUserId);

  final String currentUserId;
}

final class ReelAuthoFollowingStatusSubscriptionRequested extends ReelEvent {
  const ReelAuthoFollowingStatusSubscriptionRequested({
    required this.ownerId,
    required this.currentUserId,
  });

  final String ownerId;
  final String currentUserId;
}

final class ReelLikersPageRequested extends ReelEvent {
  const ReelLikersPageRequested({this.page = 0});

  final int page;
}

final class ReelLikeRequested extends ReelEvent {
  const ReelLikeRequested(this.userId);

  final String userId;
}

final class ReelAuthorSubscribeRequested extends ReelEvent {
  const ReelAuthorSubscribeRequested({
    required this.authorId,
    required this.currentUserId,
  });

  final String authorId;
  final String currentUserId;
}

final class ReelDeleteRequested extends ReelEvent {
  const ReelDeleteRequested(this.id);

  final String id;
}
