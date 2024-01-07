part of 'user_stories_bloc.dart';

sealed class UserStoriesEvent extends Equatable {
  const UserStoriesEvent();

  @override
  List<Object> get props => [];
}

final class UserStoriesSubscriptionRequested extends UserStoriesEvent {
  const UserStoriesSubscriptionRequested();
}

final class UserStoriesStorySeenRequested extends UserStoriesEvent {
  const UserStoriesStorySeenRequested(this.story);

  final Story story;

  @override
  List<Object> get props => [story];
}

final class UserStoriesStoryDeleteRequested extends UserStoriesEvent {
  const UserStoriesStoryDeleteRequested(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}
