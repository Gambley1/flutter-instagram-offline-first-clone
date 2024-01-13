import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:database_client/database_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/shared.dart';
import 'package:storage/storage.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart' show User;

part 'stories_storage.dart';

/// {@template stories_repository}
/// A repository that manages stories data flow.
/// {@endtemplate}
class StoriesRepository extends StoriesBaseRepository {
  /// {@macro stories_repository}
  const StoriesRepository({
    required Client client,
    required StoriesStorage storage,
  })  : _client = client,
        _storage = storage;

  final Client _client;
  final StoriesStorage _storage;

  @override
  Future<void> createStory({
    required User author,
    required StoryContentType contentType,
    required String contentUrl,
    String? id,
    int? duration,
  }) =>
      _client.createStory(
        id: id,
        author: author,
        contentType: contentType,
        contentUrl: contentUrl,
        duration: duration,
      );

  @override
  Future<String> uploadStoryMedia({
    required String storyId,
    required File imageFile,
    required Uint8List imageBytes,
  }) =>
      _client.uploadStoryMedia(
        storyId: storyId,
        imageFile: imageFile,
        imageBytes: imageBytes,
      );

  @override
  Future<void> deleteStory({required String id}) => _client.deleteStory(id: id);

  @override
  Stream<List<Story>> getStories({
    required String userId,
    bool includeAuthor = true,
  }) =>
      _client.getStories(userId: userId, includeAuthor: includeAuthor);

  @override
  Future<Story> getStory({required String id}) => _client.getStory(id: id);

  /// Broadcasts stories from database and local storage. Combines and merges
  /// into a single stories data flow.
  Stream<List<Story>> mergedStories({
    required String authorId,
    required String userId,
  }) =>
      Rx.combineLatest2(
        getStories(userId: authorId, includeAuthor: false),
        _storage._seenStoriesStreamController,
        (dbStories, localStories) => _storage.mergeStories(
          dbStories,
          userId: userId,
          list2: localStories
              .firstWhereOrNull((seenStories) => seenStories.userId == userId)
              ?.stories,
        ),
      ).asBroadcastStream();

  /// Upldates localy single user [story] as seen.
  Future<void> setUserStorySeen({
    required Story story,
    required String userId,
  }) =>
      _storage.setUserStorySeen(story, userId);
}
