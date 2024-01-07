part of 'stories_repository.dart';

/// Storage keys for the [StoriesStorage].
abstract class StoriesStorageKeys {
  /// The collection of the stories that user has already seen.
  static const userSeenStoriesCollection = '__user_seen_stories_collection__';
}

/// {@template stories_storage}
/// Storage for the [StoriesRepository].
/// {@endtemplate}
class StoriesStorage {
  /// {@macro stories_storage}
  StoriesStorage({
    required Storage storage,
  }) : _storage = storage {
    _init();
  }

  final Storage _storage;

  final _storiesStreamController =
      BehaviorSubject<List<Story>>.seeded(const []);

  FutureOr<String?> _getValue() =>
      _storage.read(key: StoriesStorageKeys.userSeenStoriesCollection);
  Future<void> _setValue(String value) => _storage.write(
        key: StoriesStorageKeys.userSeenStoriesCollection,
        value: value,
      );

  FutureOr<void> _init() async {
    final storiesJson = await _getValue();
    if (storiesJson != null) {
      final stories = List<Map<dynamic, dynamic>>.from(
        json.decode(storiesJson) as List,
      )
          .map((jsonMap) => Story.fromJson(Map<String, dynamic>.from(jsonMap)))
          .toList();
      _storiesStreamController.add(stories);
    } else {
      _storiesStreamController.add(const []);
    }
  }

  /// Finds stories in `list2` that have `IDs` not present in [list1].
  /// Iterates over the merged list and checks if the current story exists
  /// in list2. If found, it creates a copy of the story with the seen flag set
  /// to true. Otherwise, it returns the original story unchanged.
  List<Story> mergeStories(List<Story> list1, {List<Story>? list2}) {
    list2 ??= [..._storiesStreamController.value];

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
  Future<void> setUserStorySeen(Story story) async {
    final stories = [..._storiesStreamController.value];
    await _clearExpiredStories(stories: stories);
    if (stories.map((e) => e.id).contains(story.id)) return;
    stories.add(story.copyWith(seen: true));

    _storiesStreamController.add(stories);
    return _setValue(json.encode(stories));
  }

  Future<void> _clearExpiredStories({List<Story>? stories}) async {
    stories ??= [..._storiesStreamController.value];
    stories.retainWhere((story) => story.expiresAt.isAfter(DateTime.now()));

    _storiesStreamController.add(stories);
    return _setValue(json.encode(stories));
  }
}
