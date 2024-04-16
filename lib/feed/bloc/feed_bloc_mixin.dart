part of 'feed_bloc.dart';

typedef PaginatedFeedResult
    = Future<({int newPage, bool hasMore, List<InstaBlock> blocks})>;

typedef ListPostMapper = List<InstaBlock> Function(List<Post> post);

/// A mixin class that provides common functionality for a feed bloc.
///
/// This mixin class is intended to be used with a `Bloc` class that handles
/// feed-related events and states.
/// It provides methods and properties for fetching feed pages, getting posts
/// by ID, updating blocks, and inserting sponsored blocks.
///
/// To use this mixin, implement the necessary dependencies:
/// - `PostsRepository` for fetching posts and post likers
/// - `FirebaseRemoteConfigRepository` for fetching remote data
///
/// Example usage:
/// ```dart
/// class MyFeedBloc extends Bloc<FeedEvent, FeedState> with FeedBlocMixin {
///   // Implement necessary dependencies
///   PostsRepository get postsRepository => ...
///   FirebaseRemoteConfigRepository get firebaseRemoteConfigRepository => ...
///
///   // Implement other methods and properties specific to your feed bloc
///   ...
/// }
/// ```
///
/// Note: This mixin assumes that the `Bloc` class has already implemented the
///  necessary event and state classes for feed-related functionality.
/// It also assumes that the `PostsRepository` and
/// `FirebaseRemoteConfigRepository` dependencies have been properly
/// initialized.
///
/// See also:
/// - `Bloc` class for handling feed-related events and states
/// - `PostsRepository` class for fetching posts and post likers
/// - `FirebaseRemoteConfigRepository` class for fetching remote data
mixin FeedBlocMixin on Bloc<FeedEvent, FeedState> {
  int get feedPageLimit => 10;
  int get reelsPageLimit => 10;

  PostsRepository get postsRepository;
  FirebaseRemoteConfigRepository get firebaseRemoteConfigRepository;

  Future<PostBlock?> getPostBy(String id) async {
    final post = await postsRepository.getPostBy(id: id);
    return post?.toPostLargeBlock();
  }

  PaginatedFeedResult fetchFeedPage({
    int page = 0,
    ListPostMapper? mapper,
    bool withSponsoredBlocks = true,
  }) async {
    final currentPage = page;
    final posts = await postsRepository.getPage(
      offset: currentPage * feedPageLimit,
      limit: feedPageLimit,
    );
    final newPage = currentPage + 1;
    final hasMore = posts.length >= feedPageLimit;

    final postLikers = await _fetchPostLikersInFollowings(posts);

    final instaBlocks =
        mapper?.call(posts) ?? postsToLargeBlocksMapper(posts, postLikers);
    if (!withSponsoredBlocks) {
      return (newPage: newPage, hasMore: hasMore, blocks: instaBlocks);
    }
    final blocks =
        await insertSponsoredBlocks(hasMore: hasMore, blocks: instaBlocks);
    return (newPage: newPage, hasMore: hasMore, blocks: blocks);
  }

  Future<List<List<User>>> _fetchPostLikersInFollowings(List<Post> posts) =>
      Stream.fromIterable(posts)
          .asyncMap(
            (post) =>
                postsRepository.getPostLikersInFollowings(postId: post.id),
          )
          .toList();

  List<InstaBlock> postsToReelBlockMapper(List<Post> posts) {
    final instaBlocks = <InstaBlock>[];
    for (final post in posts.where((post) => post.media.isReel)) {
      final reel = post.toPostReelBlock;
      instaBlocks.add(reel);
    }
    return instaBlocks;
  }

  List<InstaBlock> postsToLargeBlocksMapper(
    List<Post> posts,
    List<List<User>> postLikers,
  ) =>
      posts.map<InstaBlock>((post) {
        final likersInFollowings = postLikers[posts.indexOf(post)];
        return post.toPostLargeBlock(likersInFollowings: likersInFollowings);
      }).toList();

  List<PostBlock> updateBlocks({
    required List<PostBlock> blocks,
    required PostBlock newBlock,
    required bool isDelete,
    required bool isFeedPage,
  }) {
    if (isFeedPage) {
      return blocks.updateWith<PostLargeBlock>(
        newItem: newBlock,
        findItemCallback: (block, newBlock) => block.id == newBlock.id,
        onUpdate: (block, newBlock) =>
            block.copyWith(caption: newBlock.caption),
        isDelete: isDelete,
      );
    }
    return blocks.updateWith<PostReelBlock>(
      newItem: newBlock,
      findItemCallback: (block, newBlock) => block.id == newBlock.id,
      onUpdate: (block, newBlock) => block.copyWith(caption: newBlock.caption),
      isDelete: isDelete,
    );
  }

  Future<List<InstaBlock>> insertSponsoredBlocks({
    required bool hasMore,
    required List<InstaBlock> blocks,
  }) async {
    final sponsoredBlocksStringJson =
        firebaseRemoteConfigRepository.fetchRemoteData('sponsored_blocks');

    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(_computeSponsoredBlocks, [
      receivePort.sendPort,
      hasMore,
      blocks,
      sponsoredBlocksStringJson,
    ]);
    isolate.kill(priority: Isolate.immediate);

    final insertedBlocks = await receivePort.first as List<InstaBlock>;
    return insertedBlocks;
  }

  static Future<void> _computeSponsoredBlocks(List<dynamic> args) async {
    final sendPort = args[0] as SendPort;
    final hasMore = args[1] as bool;
    final blocks = args[2] as List<InstaBlock>;
    final sponsoredBlocksListJson =
        List<Map<String, dynamic>>.from(jsonDecode(args[3] as String) as List);

    // Limit insertion to 20 sponsored posts to avoid overwhelming UI
    final sponsored =
        sponsoredBlocksListJson.take(20).map(InstaBlock.fromJson).toList();

    // Use a more descriptive variable name
    final numSponsoredBlocks = sponsored.length;

    void insertSponsoredPost(int index) {
      blocks.insert(index, sponsored[Random().nextInt(numSponsoredBlocks)]);
    }

    for (var i = blocks.length - 1; i > 0; i--) {
      // Simplify skip logic using a single random value
      final shouldSkip = Random().nextBool();

      if (shouldSkip) {
        insertSponsoredPost(i);
      }
    }

    if (!hasMore) {
      blocks.addAll([
        if (blocks.isNotEmpty) DividerHorizontalBlock(),
        const SectionHeaderBlock(
          sectionType: SectionHeaderBlockType.suggested,
        ),
      ]);
    }

    return sendPort.send(blocks);
  }
}
