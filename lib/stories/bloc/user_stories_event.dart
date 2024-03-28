part of 'user_stories_bloc.dart';

sealed class UserStoriesEvent extends Equatable {
  const UserStoriesEvent();

  @override
  List<Object> get props => [];
}

final class UserStoriesSubscriptionRequested extends UserStoriesEvent {
  const UserStoriesSubscriptionRequested(this.userId);

  final String userId;
}

final class UserStoriesStorySeenRequested extends UserStoriesEvent {
  const UserStoriesStorySeenRequested(this.story, this.userId);

  final Story story;
  final String userId;

  @override
  List<Object> get props => [story, userId];
}

final class UserStoriesStoryDeleteRequested extends UserStoriesEvent {
  const UserStoriesStoryDeleteRequested(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}
