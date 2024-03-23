import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required PostsRepository postsRepository,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
  })  : _postsRepository = postsRepository,
        _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository,
        super(const FeedState.initial()) {
    on<FeedPageRequested>(_onPageRequested, transformer: throttleDroppable());
    on<FeedReelsPageRequested>(_onFeedReelsPageRequested);
    on<FeedRefreshRequested>(
      _onRefreshRequested,
      transformer: throttleDroppable(duration: 550.ms),
    );
    on<FeedRecommenedPostsPageRequested>(
      _onFeedRecommenedPostsPageRequested,
      transformer: throttleDroppable(),
    );
    on<FeedPostCreateRequested>(_onFeedPostCreateRequested);
    on<FeedUpdateRequested>(_onFeedUpdateRequested);
  }

  final _recommenedPosts = <PostLargeBlock>[
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: Random().nextInt(60),
          hours: Random().nextInt(24),
          days: Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/free-photo/morskie-oko-tatry_1204-510.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: Random().nextInt(60),
          hours: Random().nextInt(24),
          days: Random().nextInt(12),
        ),
      ),
      media: [
        VideoMedia(
          id: uuid.v4(),
          firstFrameUrl: '',
          url:
              'https://player.vimeo.com/progressive_redirect/playback/903856061/rendition/540p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=1bf8c7fcb5788b45eb5b8b30519f1eb872eb5be562ef9b0e04191ee44d53acff',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: Random().nextInt(60),
          hours: Random().nextInt(24),
          days: Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/free-photo/beautiful-shot-high-mountains-covered-with-green-plants-near-lake-storm-clouds_181624-7731.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: Random().nextInt(60),
          hours: Random().nextInt(24),
          days: Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/free-photo/landscape-morning-fog-mountains-with-hot-air-balloons-sunrise_335224-794.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: Random().nextInt(60),
          hours: Random().nextInt(24),
          days: Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/free-photo/magical-shot-dolomite-mountains-fanes-sennes-prags-national-park-italy-during-summer_181624-43445.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: Random().nextInt(60),
          hours: Random().nextInt(24),
          days: Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/free-photo/morskie-oko-tatry_1204-510.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: Random().nextInt(60),
          hours: Random().nextInt(24),
          days: Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/premium-photo/clouds-is-top-wooden-boat-crystal-lake-with-majestic-mountain-reflection-water-chapel-is-right-coast_146671-14200.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: Random().nextInt(60),
          hours: Random().nextInt(24),
          days: Random().nextInt(12),
        ),
      ),
      media: [
        VideoMedia(
          id: uuid.v4(),
          firstFrameUrl: '',
          url:
              'https://player.vimeo.com/progressive_redirect/playback/899246570/rendition/540p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=40dde4d43100a4ef1b77b713dee18a003757a7748ffab1cfbddce2818c818283',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: Random().nextInt(60),
          hours: Random().nextInt(24),
          days: Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/premium-photo/clouds-is-top-wooden-boat-crystal-lake-with-majestic-mountain-reflection-water-chapel-is-right-coast_146671-14200.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: Random().nextInt(60),
          hours: Random().nextInt(24),
          days: Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/premium-photo/clouds-is-top-wooden-boat-crystal-lake-with-majestic-mountain-reflection-water-chapel-is-right-coast_146671-14200.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
  ].withNavigateToPostAuthorAction;

  static const _feedPageLimit = 10;
  static const _reelsPageLimit = 10;

  final PostsRepository _postsRepository;
  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;

  List<InstaBlock> insertSponsoredBlocks({
    required bool hasMore,
    required List<InstaBlock> blocks,
    required int page,
    List<InstaBlock>? sponsoredBlocks,
  }) {
    final random = Random();

    var tempBlocks = [...blocks];
    var tempDataLength = tempBlocks.length;

    final skipRange = [1, 2, 3];
    var previosSkipRangeIs1 = false;

    late final sponsored = sponsoredBlocks ??
        List<Map<String, dynamic>>.from(
          jsonDecode(
            _firebaseRemoteConfigRepository.fetchRemoteData('sponsored_blocks'),
          ) as List,
        ).map(InstaBlock.fromJson).take(20).toList();

    while (tempDataLength > 1) {
      List<int> allowedSkipRange() {
        if (previosSkipRangeIs1 && tempDataLength > 3) {
          return skipRange.sublist(1);
        }
        if (tempDataLength == 2) return [1];
        if (tempDataLength == 3) return [1, 2];
        return skipRange;
      }

      final randomSponsoredPost = sponsored[random.nextInt(sponsored.length)];

      final randomSkipRange =
          allowedSkipRange()[random.nextInt(allowedSkipRange().length)];

      previosSkipRangeIs1 = randomSkipRange == 1;

      tempBlocks = tempBlocks.sublist(randomSkipRange);
      blocks.insert(blocks.length - tempBlocks.length, randomSponsoredPost);
      tempDataLength = tempBlocks.length;
    }

    if (!hasMore) {
      return blocks.followedBy([
        if (blocks.isNotEmpty) DividerHorizontalBlock(),
        const SectionHeaderBlock(sectionType: SectionHeaderBlockType.suggested),
      ]).toList();
    }

    return blocks;
  }

  Future<void> _onPageRequested(
    FeedPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    try {
      final currentPage = event.page ?? state.feed.feedPage.page;
      final posts = await _postsRepository.getPage(
        offset: currentPage * _feedPageLimit,
        limit: _feedPageLimit,
      );
      final postLikersFutures = posts.map(
        (post) => _postsRepository.getPostLikersInFollowings(postId: post.id),
      );
      final postLikers = await Future.wait(postLikersFutures);

      final newPage = currentPage + 1;

      final hasMore = posts.length >= _feedPageLimit;

      final instaBlocks = List<InstaBlock>.generate(posts.length, (index) {
        final likersInFollowings = postLikers[index];
        final post = posts[index]
            .toPostLargeBlock(likersInFollowings: likersInFollowings);
        return post;
      });
      final blocks = insertSponsoredBlocks(
        hasMore: hasMore,
        blocks: instaBlocks,
        page: currentPage,
      );

      final feed = state.feed.copyWith(
        feedPage: state.feed.feedPage.copyWith(
          page: newPage,
          hasMore: hasMore,
          blocks: [...state.feed.feedPage.blocks, ...blocks],
          totalBlocks: state.feed.feedPage.totalBlocks + blocks.length,
        ),
      );

      emit(state.populated(feed: feed));

      if (!hasMore) add(const FeedRecommenedPostsPageRequested());
    } catch (error, stackTrace) {
      logE(
        'Failed to request feed page.',
        error: error,
        stackTrace: stackTrace,
      );
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  Future<void> _onFeedReelsPageRequested(
    FeedReelsPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    try {
      final currentPage = event.page ?? state.feed.reelsPage.page;
      final posts = await _postsRepository.getPage(
        offset: currentPage * _reelsPageLimit,
        limit: _reelsPageLimit,
        onlyReels: true,
      );
      final instaBlocks = <PostBlock>[];

      final newPage = currentPage + 1;
      final hasMore = posts.length >= _reelsPageLimit;

      for (final post in posts.where((post) => post.media.isReel)) {
        final reel = post.toPostReelBlock;
        instaBlocks.add(reel);
      }

      final feed = state.feed.copyWith(
        reelsPage: state.feed.reelsPage.copyWith(
          page: newPage,
          hasMore: hasMore,
          blocks: [...state.feed.reelsPage.blocks, ...instaBlocks],
          totalBlocks: state.feed.reelsPage.totalBlocks + instaBlocks.length,
        ),
      );
      emit(state.populated(feed: feed));
    } catch (error, stackTrace) {
      logE(
        '[FeedBloc] Feed Reels page fetching failed.',
        error: error,
        stackTrace: stackTrace,
      );
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  Future<void> _onRefreshRequested(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    try {
      const page = 0;
      final posts = await _postsRepository.getPage(
        offset: page * _feedPageLimit,
        limit: _feedPageLimit,
      );
      final postLikersFutures = posts.map(
        (post) => _postsRepository.getPostLikersInFollowings(postId: post.id),
      );
      final postLikers = await Future.wait(postLikersFutures);

      final hasMore = posts.length >= _feedPageLimit;
      final instaBlocks = List<InstaBlock>.generate(posts.length, (index) {
        final likersInFollowings = postLikers[index];
        final post = posts[index]
            .toPostLargeBlock(likersInFollowings: likersInFollowings);
        return post;
      });
      final blocks = insertSponsoredBlocks(
        hasMore: hasMore,
        blocks: instaBlocks,
        page: page,
      );

      final feed = state.feed.copyWith(
        feedPage: FeedPage(
          blocks: blocks,
          totalBlocks: blocks.length,
          page: page + 1,
          hasMore: hasMore,
        ),
      );

      emit(state.populated(feed: feed));

      if (!hasMore) add(const FeedRecommenedPostsPageRequested());
    } catch (error, stackTrace) {
      logE(
        'Failed to refresh feed page.',
        error: error,
        stackTrace: stackTrace,
      );
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  Future<PostBlock?> getPostBy(String id) async {
    final post = await _postsRepository.getPostBy(id: id);
    return post?.toPostLargeBlock();
  }

  Future<void> _onFeedRecommenedPostsPageRequested(
    FeedRecommenedPostsPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    try {
      final recommenedBlocks = <InstaBlock>[..._recommenedPosts..shuffle()];
      final blocks = insertSponsoredBlocks(
        hasMore: true,
        blocks: recommenedBlocks,
        page: 0,
      );

      final feed = state.feed.copyWith(
        feedPage: state.feed.feedPage.copyWith(
          page: state.feed.feedPage.page,
          hasMore: state.feed.feedPage.hasMore,
          blocks: [...state.feed.feedPage.blocks, ...blocks],
          totalBlocks: state.feed.feedPage.totalBlocks + blocks.length,
        ),
      );

      emit(state.populated(feed: feed));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  Future<void> _onFeedPostCreateRequested(
    FeedPostCreateRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    try {
      final newPost = await _postsRepository.createPost(
        id: event.postId,
        userId: event.userId,
        caption: event.caption,
        media: json.encode(event.media),
      );
      if (newPost != null) {
        add(
          FeedUpdateRequested(
            post: newPost,
            isCreate: true,
          ),
        );
      }
      emit(state.populated());
      toggleLoadingIndeterminate(enable: false);
      openSnackbar(
        const SnackbarMessage.success(
          title: 'Successfully created post!',
        ),
      );
    } catch (error, stackTrace) {
      logE('Failed to create post.', error: error, stackTrace: stackTrace);
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  Future<void> _onFeedUpdateRequested(
    FeedUpdateRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    final oldFeed = state.feed;

    try {
      final feedPost = oldFeed.feedPage.blocks.firstWhereOrNull(
        (block) =>
            (block.type == PostLargeBlock.identifier ||
                block.type == PostSponsoredBlock.identifier) &&
            (block is PostBlock) &&
            block.id == event.post.id,
      ) as PostBlock?;
      final reel = oldFeed.reelsPage.blocks.firstWhereOrNull(
        (block) =>
            (block.type == PostReelBlock.identifier) &&
            (block is PostBlock) &&
            block.id == event.post.id,
      ) as PostBlock?;
      if (feedPost == null && reel == null && !event.isCreate) {
        emit(state.populated());
        return;
      }
      final updatedFeedBlocks = _updateBlocks(
        blocks: oldFeed.feedPage.blocks.whereType<PostBlock>().toList(),
        newBlock: event.post.toPostLargeBlock(),
        isDelete: event.isDelete,
        isFeedPage: true,
      );
      List<InstaBlock>? updatedReelsBlocks;
      if (((!event.isCreate && !event.isDelete) && reel != null) ||
          (event.post.media.isReel)) {
        updatedReelsBlocks = _updateBlocks(
          blocks: oldFeed.reelsPage.blocks.whereType<PostBlock>().toList(),
          newBlock: event.post.toPostReelBlock,
          isDelete: event.isDelete,
          isFeedPage: false,
        );
      }

      final feed = state.feed.copyWith(
        feedPage: state.feed.feedPage.copyWith(
          blocks: updatedFeedBlocks,
          totalBlocks: updatedFeedBlocks.length,
        ),
        reelsPage: state.feed.reelsPage.copyWith(
          blocks: updatedReelsBlocks,
          totalBlocks: updatedReelsBlocks?.length,
        ),
      );

      emit(state.populated(feed: feed));
    } catch (error, stackTrace) {
      logE('Failed to update feed post.', error: error, stackTrace: stackTrace);
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  List<PostBlock> _updateBlocks({
    required List<PostBlock> blocks,
    required PostBlock newBlock,
    required bool isDelete,
    required bool isFeedPage,
  }) {
    if (isFeedPage) {
      return blocks.updateWith<PostLargeBlock>(
        newItem: newBlock,
        findCallback: (block, newBlock) => block.id == newBlock.id,
        onUpdate: (block, newBlock) =>
            block.copyWith(caption: newBlock.caption),
        isDelete: isDelete,
      );
    }
    return blocks.updateWith<PostReelBlock>(
      newItem: newBlock,
      findCallback: (block, newBlock) => block.id == newBlock.id,
      onUpdate: (block, newBlock) => block.copyWith(caption: newBlock.caption),
      isDelete: isDelete,
    );
  }
}

extension PostX on Post {
  /// Converts [Post] instance into [PostLargeBlock] instance.
  PostLargeBlock toPostLargeBlock({List<User> likersInFollowings = const []}) =>
      PostLargeBlock(
        id: id,
        author: PostAuthor.confirmed(
          id: author.id,
          avatarUrl: author.avatarUrl,
          username: author.displayUsername,
        ),
        createdAt: createdAt,
        media: media,
        caption: caption,
        likersInFollowings: likersInFollowings,
        action: NavigateToPostAuthorProfileAction(authorId: author.id),
      );

  /// Converts [Post] instance into [PostSmallBlock] instance.
  PostSmallBlock get toPostSmallBlock => PostSmallBlock(
        id: id,
        author: PostAuthor.confirmed(
          id: author.id,
          avatarUrl: author.avatarUrl,
          username: author.displayUsername,
        ),
        createdAt: createdAt,
        media: media,
        caption: caption,
        action: NavigateToPostAuthorProfileAction(authorId: author.id),
      );

  PostReelBlock get toPostReelBlock => PostReelBlock(
        id: id,
        author: PostAuthor.confirmed(
          id: author.id,
          avatarUrl: author.avatarUrl,
          username: author.displayUsername,
        ),
        createdAt: createdAt,
        media: media,
        caption: caption,
      );
}

extension PostsX on List<PostLargeBlock> {
  List<PostLargeBlock> get withNavigateToPostAuthorAction => map(
        (e) => e.copyWith(
          action: NavigateToPostAuthorProfileAction(authorId: e.author.id),
        ),
      ).toList();
}
