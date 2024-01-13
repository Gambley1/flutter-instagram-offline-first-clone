part of 'create_stories_bloc.dart';

sealed class CreateStoriesEvent extends Equatable {
  const CreateStoriesEvent();

  @override
  List<Object?> get props => [];
}

final class CreateStoriesFeatureAvaiableSubscriptionRequested
    extends CreateStoriesEvent {
  const CreateStoriesFeatureAvaiableSubscriptionRequested();
}

final class CreateStoriesStoryCreateRequested extends CreateStoriesEvent {
  const CreateStoriesStoryCreateRequested({
    required this.author,
    required this.contentType,
    required this.filePath,
    this.onStoryCreated,
    this.onError,
    this.onLoading,
    this.duration,
  });

  final User author;
  final StoryContentType contentType;
  final String filePath;
  final int? duration;
  final VoidCallback? onStoryCreated;
  final VoidCallback? onLoading;
  final void Function(Object?, StackTrace?)? onError;

  @override
  List<Object?> get props => [author, contentType, filePath, duration];
}

final class CreateStoriesStoryDeleteRequested extends CreateStoriesEvent {
  const CreateStoriesStoryDeleteRequested({
    required this.id,
    this.onStoryDeleted,
  });

  final String id;
  final VoidCallback? onStoryDeleted;

  @override
  List<Object?> get props => [id, onStoryDeleted];
}
