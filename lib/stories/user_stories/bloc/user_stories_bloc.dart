import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'user_stories_bloc.g.dart';
part 'user_stories_event.dart';
part 'user_stories_state.dart';

class UserStoriesBloc extends HydratedBloc<UserStoriesEvent, UserStoriesState> {
  UserStoriesBloc({
    required User author,
    required StoriesRepository storiesRepository,
  })  : _author = author,
        _storiesRepository = storiesRepository,
        super(const UserStoriesState.initial()) {
    on<UserStoriesSubscriptionRequested>(_onUserStoriesSubscriptionRequested);
    on<UserStoriesStorySeenRequested>(_onUserStoriesStorySeenRequested);
    on<UserStoriesStoryDeleteRequested>(_onUserStoriesStoryDeleteRequested);
  }

  final User _author;
  final StoriesRepository _storiesRepository;

  @override
  String get id => _author.id;

  Future<void> _onUserStoriesSubscriptionRequested(
    UserStoriesSubscriptionRequested event,
    Emitter<UserStoriesState> emit,
  ) async {
    emit(state.copyWith(author: _author));
    await emit.forEach(
      _storiesRepository.mergedStories(
        authorId: _author.id,
        userId: event.userId,
      ),
      onData: (stories) => state.copyWith(
        stories: stories,
        showStories: stories.any((e) => !e.seen),
      ),
    );
  }

  Future<void> _onUserStoriesStorySeenRequested(
    UserStoriesStorySeenRequested event,
    Emitter<UserStoriesState> emit,
  ) =>
      _storiesRepository.setUserStorySeen(
        story: event.story,
        userId: event.userId,
      );

  Future<void> _onUserStoriesStoryDeleteRequested(
    UserStoriesStoryDeleteRequested event,
    Emitter<UserStoriesState> emit,
  ) =>
      _storiesRepository.deleteStory(id: event.id);

  @override
  UserStoriesState? fromJson(Map<String, dynamic> json) =>
      UserStoriesState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(UserStoriesState state) => state.toJson();
}
