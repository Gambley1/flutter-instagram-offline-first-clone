import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_config/firebase_config.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'create_stories_event.dart';
part 'create_stories_state.dart';

class CreateStoriesBloc extends Bloc<CreateStoriesEvent, CreateStoriesState> {
  CreateStoriesBloc({
    required StoriesRepository storiesRepository,
    required FirebaseConfig remoteConfig,
  })  : _storiesRepository = storiesRepository,
        _remoteConfig = remoteConfig,
        super(const CreateStoriesState.intital()) {
    on<CreateStoriesStoryCreateRequested>(_onStoryCreateRequested);
    on<CreateStoriesIsFeatureAvaiableSubscriptionRequested>(
      _onCreateStoriesFeatureAvaiableSubscriptionRequested,
      transformer: throttleDroppable(),
    );
  }

  final StoriesRepository _storiesRepository;
  final FirebaseConfig _remoteConfig;

  Future<void> _onCreateStoriesFeatureAvaiableSubscriptionRequested(
    CreateStoriesIsFeatureAvaiableSubscriptionRequested event,
    Emitter<CreateStoriesState> emit,
  ) async {
    final storiesEnabled =
        _remoteConfig.isFeatureAvailabe('enable_create_stories');
    emit(state.copyWith(isAvailable: storiesEnabled));

    await emit.onEach(
      _remoteConfig.onConfigUpdated(),
      onData: (data) {
        _remoteConfig.activate();

        final storiesEnabled =
            _remoteConfig.isFeatureAvailabe('enable_create_stories');

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

      final storyId = UidGenerator.v4();
      final storyImageFile = File(event.filePath);
      final compressed = await ImageCompress.compressFile(storyImageFile);
      final compressedFile = File(compressed!.path);
      final compressedBytes =
          await PickImage.instance.imageBytes(file: compressedFile);
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
