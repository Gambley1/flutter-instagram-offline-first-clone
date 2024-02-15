part of 'stories_bloc.dart';

sealed class StoriesEvent extends Equatable {
  const StoriesEvent();

  @override
  List<Object?> get props => [];
}

final class StoriesFetchUserFollowingsStories extends StoriesEvent {
  const StoriesFetchUserFollowingsStories(this.userId);

  final String userId;

  @override
  List<Object> get props => [userId];
}

final class StoriesStorySeen extends StoriesEvent {
  const StoriesStorySeen(this.story, this.userId);

  final Story story;
  final String userId;

  @override
  List<Object?> get props => [story, userId];
}

final class StoriesStoryDeleteRequested extends StoriesEvent {
  const StoriesStoryDeleteRequested({
    required this.id,
    this.onStoryDeleted,
  });

  final String id;
  final VoidCallback? onStoryDeleted;

  @override
  List<Object?> get props => [id, onStoryDeleted];
}
