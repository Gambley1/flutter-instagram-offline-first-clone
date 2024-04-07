import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart'
    show FicIterableExtension;
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'stories_event.dart';
part 'stories_state.dart';

class StoriesBloc extends Bloc<StoriesEvent, StoriesState> {
  StoriesBloc({
    required StoriesRepository storiesRepository,
    required UserRepository userRepository,
  })  : _storiesRepository = storiesRepository,
        _userRepository = userRepository,
        super(const StoriesState.initial()) {
    on<StoriesFetchUserFollowingsStories>(_onStoriesFetchUserFollowingsStories);
    on<StoriesStorySeen>(_onStoriesStorySeen);
    on<StoriesStoryDeleteRequested>(_onStoriesStoryDeleteRequested);
  }

  final StoriesRepository _storiesRepository;
  final UserRepository _userRepository;

  Future<void> _onStoriesFetchUserFollowingsStories(
    StoriesFetchUserFollowingsStories event,
    Emitter<StoriesState> emit,
  ) async {
    final followings = await _userRepository.getFollowings();
    final stories = <User, List<Story>>{};
    for (final following in followings) {
      try {
        final userStories = await _storiesRepository
            .mergedStories(authorId: following.id)
            .first;
        if (state.users.map((e) => e.id).contains(following.id) &&
            userStories.isEmpty) {
          emit(state.copyWith(users: [...state.users]..remove(following)));
        }
        if (userStories.isEmpty) continue;
        stories[following] = userStories;
      } catch (error, stackTrace) {
        addError(error, stackTrace);
        emit(state.copyWith(status: StoriesStatus.failure));
      }
    }
    final users = stories.keys
            .every((user) => stories[user]!.every((story) => story.seen))
        ? stories.keys.toList()
        : stories.keys
            .toIList()
            .whereMoveToTheEnd(
              (user) => stories[user]!.every((story) => story.seen),
            )
            .toList();
    emit(state.copyWith(users: users, status: StoriesStatus.success));
  }

  Future<void> _onStoriesStorySeen(
    StoriesStorySeen event,
    Emitter<StoriesState> emit,
  ) =>
      _storiesRepository.setUserStorySeen(
        story: event.story,
        userId: event.userId,
      );

  Future<void> _onStoriesStoryDeleteRequested(
    StoriesStoryDeleteRequested event,
    Emitter<StoriesState> emit,
  ) async {
    try {
      await _storiesRepository.deleteStory(id: event.id);

      event.onStoryDeleted?.call();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      logE('Failed to delete story.', error: error, stackTrace: stackTrace);
    }
  }
}
