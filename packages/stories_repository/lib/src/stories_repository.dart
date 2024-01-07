import 'dart:async';
import 'dart:convert';

import 'package:database_client/database_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/shared.dart';
import 'package:storage/storage.dart';
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
  }) =>
      _client.createStory(
        author: author,
        contentType: contentType,
        contentUrl: contentUrl,
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
  Stream<List<Story>> mergedStories({required String userId}) =>
      Rx.combineLatest2(
        getStories(userId: userId, includeAuthor: false),
        _storage._storiesStreamController,
        (dbStories, localStories) =>
            _storage.mergeStories(dbStories, list2: localStories),
      ).asBroadcastStream();

  /// Upldates localy single user [story] as seen.
  Future<void> setUserStorySeen({required Story story}) =>
      _storage.setUserStorySeen(story);
}
