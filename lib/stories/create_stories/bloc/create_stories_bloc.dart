import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'create_stories_event.dart';
part 'create_stories_state.dart';

class CreateStoriesBloc extends Bloc<CreateStoriesEvent, CreateStoriesState> {
  CreateStoriesBloc({
    required StoriesRepository storiesRepository,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
  })  : _storiesRepository = storiesRepository,
        _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository,
        super(const CreateStoriesState.initial()) {
    on<CreateStoriesStoryCreateRequested>(_onStoryCreateRequested);
    on<CreateStoriesIsFeatureAvaiableSubscriptionRequested>(
      _onCreateStoriesFeatureAvaiableSubscriptionRequested,
      transformer: throttleDroppable(),
    );
  }

  final StoriesRepository _storiesRepository;
  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;

  Future<void> _onCreateStoriesFeatureAvaiableSubscriptionRequested(
    CreateStoriesIsFeatureAvaiableSubscriptionRequested event,
    Emitter<CreateStoriesState> emit,
  ) async {
    final storiesEnabled = _firebaseRemoteConfigRepository
        .isFeatureAvailable('enable_create_stories');
    emit(state.copyWith(isAvailable: storiesEnabled));

    await emit.onEach(
      _firebaseRemoteConfigRepository.onConfigUpdated(),
      onData: (data) {
        _firebaseRemoteConfigRepository.activate();

        final storiesEnabled = _firebaseRemoteConfigRepository
            .isFeatureAvailable('enable_create_stories');

        emit(state.copyWith(isAvailable: !storiesEnabled));
      },
    );
  }

  Future<void> _onStoryCreateRequested(
    CreateStoriesStoryCreateRequested event,
    Emitter<CreateStoriesState> emit,
  ) async {
    try {
      event.onLoading?.call();

      final storyId = uuid.v4();
      final storyImageFile = File(event.filePath);
      final compressed = await ImageCompress.compressFile(storyImageFile);
      final compressedFile = File(compressed!.path);
      final compressedBytes =
          await PickImage().imageBytes(file: compressedFile);
      final contentUrl = await _storiesRepository.uploadStoryMedia(
        storyId: storyId,
        imageFile: compressedFile,
        imageBytes: compressedBytes,
      );

      await _storiesRepository.createStory(
        id: storyId,
        author: event.author,
        contentType: event.contentType,
        contentUrl: contentUrl,
        duration: event.duration,
      );

      event.onStoryCreated?.call();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      event.onError?.call(error, stackTrace);
    }
  }
}
