part of 'stories_repository.dart';

/// Storage keys for the [StoriesStorage].
abstract class StoriesStorageKeys {
  /// The collection of the stories that user has already seen.
  static const userSeenStoriesCollection = '__user_seen_stories_collection__';
}

/// {@template stories_storage}
/// Manages storage and retrieval of seen stories for users.
/// {@endtemplate}
class StoriesStorage {
  /// {@macro stories_storage}
  StoriesStorage({
    required Storage storage,
  }) : _storage = storage {
    _init();
  }

  final Storage _storage;

  final _seenStoriesStreamController =
      BehaviorSubject<List<SeenStories>>.seeded(const []);

  FutureOr<String?> _getValue() =>
      _storage.read(key: StoriesStorageKeys.userSeenStoriesCollection);
  Future<void> _setValue(String value) => _storage.write(
        key: StoriesStorageKeys.userSeenStoriesCollection,
        value: value,
      );

  FutureOr<void> _init() async {
    final seenStoriesJson = await _getValue();
    if (seenStoriesJson != null) {
      final seenStories = List<Map<dynamic, dynamic>>.from(
        json.decode(seenStoriesJson) as List,
      )
          .map(
            (jsonMap) =>
                SeenStories.fromJson(Map<String, dynamic>.from(jsonMap)),
          )
          .toList();
      _seenStoriesStreamController.add(seenStories);
      await _clearExpiredStories();
    } else {
      _seenStoriesStreamController.add(const []);
    }
  }

  /// Finds stories in `list2` that have `IDs` not present in [list1].
  /// Iterates over the merged list and checks if the current story exists
  /// in list2. If found, it creates a copy of the story with the seen flag set
  /// to true. Otherwise, it returns the original story unchanged.
  List<Story> mergeStories(
    List<Story> list1, {
    String? userId,
    List<Story>? list2,
  }) {
    list2 ??= [
      ...?_seenStoriesStreamController.value
          .firstWhereOrNull((seenStories) => seenStories.userId == userId)
          ?.stories,
    ];

    // Merge lists and update seen flag if story is found in list2
    return list1
        .map(
          (story) => list2!.map((e) => e.id).contains(story.id)
              ? story.copyWith(seen: true)
              : story,
        )
        .toList();
  }

  /// Adds [story] to the local list of seen stories.
  Future<void> setUserStorySeen(Story story, String userId) async {
    final seenStories = [..._seenStoriesStreamController.value];
    await _clearExpiredStories(seenStories: seenStories);
    final seenStoriesByUser = seenStories.firstWhere(
      (seenStories) => seenStories.userId == userId,
      orElse: () => SeenStories.empty,
    );
    if (seenStoriesByUser.stories.map((story) => story.id).contains(story.id)) {
      return;
    }
    if (seenStoriesByUser != SeenStories.empty) {
      seenStories
          .firstWhereOrNull(
            (seenStories) => seenStories.userId == seenStoriesByUser.userId,
          )
          ?.stories
          .add(story.copyWith(seen: true));
    } else {
      seenStories.add(
        seenStoriesByUser.copyWith(
          userId: userId,
          stories: [story.copyWith(seen: true)],
        ),
      );
    }

    _seenStoriesStreamController.add(seenStories);
    return _setValue(json.encode(seenStories));
  }

  Future<void> _clearExpiredStories({List<SeenStories>? seenStories}) async {
    seenStories ??= [..._seenStoriesStreamController.value];
    seenStories.map(
      (seenStories) => seenStories.stories.retainWhere(
        (story) => story.expiresAt.isAfter(DateTime.now()),
      ),
    );

    _seenStoriesStreamController.add(seenStories);
    return _setValue(json.encode(seenStories));
  }
}
