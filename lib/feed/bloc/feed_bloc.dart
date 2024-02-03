import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_config/firebase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required PostsRepository postsRepository,
    required UserRepository userRepository,
    required FirebaseConfig remoteConfig,
  })  : _postsRepository = postsRepository,
        _userRepository = userRepository,
        _remoteConfig = remoteConfig,
        super(const FeedState.initial()) {
    on<FeedPageRequested>(_onPageRequested, transformer: throttleDroppable());
    on<FeedRefreshRequested>(
      _onRefreshRequested,
      transformer: throttleDroppable(),
    );
    on<FeedLikePostRequested>(_onPostLiked, transformer: sequential());
    on<FeedPostAuthorFollowRequested>(_onFollow);
    on<FeedPostShareRequested>(_onFeedPostShareRequested);
    on<FeedRecommenedPostsPageRequested>(_onFeedRecommenedPostsPageRequested);
  }

  final _recommenedPosts = <InstaBlock>[
    PostLargeBlock(
      id: UidGenerator.v4(),
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
          id: UidGenerator.v4(),
          url:
              'https://img.freepik.com/free-photo/morskie-oko-tatry_1204-510.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: UidGenerator.v4(),
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
          id: UidGenerator.v4(),
          firstFrameUrl: '',
          url:
              'https://player.vimeo.com/progressive_redirect/playback/903856061/rendition/540p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=1bf8c7fcb5788b45eb5b8b30519f1eb872eb5be562ef9b0e04191ee44d53acff',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: UidGenerator.v4(),
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
          id: UidGenerator.v4(),
          url:
              'https://img.freepik.com/free-photo/beautiful-shot-high-mountains-covered-with-green-plants-near-lake-storm-clouds_181624-7731.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: UidGenerator.v4(),
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
          id: UidGenerator.v4(),
          url:
              'https://img.freepik.com/free-photo/landscape-morning-fog-mountains-with-hot-air-balloons-sunrise_335224-794.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: UidGenerator.v4(),
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
          id: UidGenerator.v4(),
          url:
              'https://img.freepik.com/free-photo/magical-shot-dolomite-mountains-fanes-sennes-prags-national-park-italy-during-summer_181624-43445.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: UidGenerator.v4(),
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
          id: UidGenerator.v4(),
          url:
              'https://img.freepik.com/free-photo/morskie-oko-tatry_1204-510.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: UidGenerator.v4(),
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
          id: UidGenerator.v4(),
          url:
              'https://img.freepik.com/premium-photo/clouds-is-top-wooden-boat-crystal-lake-with-majestic-mountain-reflection-water-chapel-is-right-coast_146671-14200.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: UidGenerator.v4(),
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
          id: UidGenerator.v4(),
          firstFrameUrl: '',
          url:
              'https://player.vimeo.com/progressive_redirect/playback/899246570/rendition/540p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=40dde4d43100a4ef1b77b713dee18a003757a7748ffab1cfbddce2818c818283',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: UidGenerator.v4(),
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
          id: UidGenerator.v4(),
          url:
              'https://img.freepik.com/premium-photo/clouds-is-top-wooden-boat-crystal-lake-with-majestic-mountain-reflection-water-chapel-is-right-coast_146671-14200.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: UidGenerator.v4(),
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
          id: UidGenerator.v4(),
          url:
              'https://img.freepik.com/premium-photo/clouds-is-top-wooden-boat-crystal-lake-with-majestic-mountain-reflection-water-chapel-is-right-coast_146671-14200.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
  ];

  static const _pageLimit = 10;

  final PostsRepository _postsRepository;
  final UserRepository _userRepository;
  final FirebaseConfig _remoteConfig;

  String get _currentUserId => _userRepository.currentUserId ?? '';

  bool isOwnerOfPostBy(String authorId) =>
      _userRepository.isOwnerOfPostBy(authorId: authorId);

  Stream<bool> isLiked(String id) => _postsRepository
      .isLiked(
        userId: _currentUserId,
        id: id,
      )
      .asBroadcastStream();

  Stream<int> likesCount(String id) =>
      _postsRepository.likesOf(id: id).asBroadcastStream();

  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  }) =>
      _userRepository.followingStatus(
        followerId: followerId ?? _currentUserId,
        userId: userId,
      );

  Stream<int> commentsCountOf(String postId) =>
      _postsRepository.commentsAmountOf(postId: postId);

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
          jsonDecode(_remoteConfig.getRemoteData('sponsored_blocks')) as List,
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
      blocks.insert(
        blocks.length - tempBlocks.length,
        randomSponsoredPost,
      );
      tempDataLength = tempBlocks.length;
    }

    if (!hasMore) {
      return blocks.followedBy([
        if (blocks.isNotEmpty) DividerHorizontalBlock(),
        SectionHeaderBlock(
          title: 'Suggested for you',
        ),
      ]).toList();
    }

    return blocks;
  }

  Future<void> _onPageRequested(
    FeedPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading));
    try {
      final currentPage = event.page ?? state.feed.page;
      final posts = await _postsRepository.getPage(
        offset: currentPage * _pageLimit,
        limit: _pageLimit,
      );
      final postLikersFutures = posts.map(
        (post) => _postsRepository.getPostLikersInFollowings(postId: post.id),
      );
      final postLikers = await Future.wait(postLikersFutures);

      final newPage = currentPage + 1;

      final hasMore = posts.length >= _pageLimit;

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
        page: newPage,
        hasMore: hasMore,
        feed: state.feed.feed.copyWith(
          blocks: [...state.feed.feed.blocks, ...blocks],
          totalBlocks: state.feed.feed.totalBlocks + blocks.length,
        ),
      );

      emit(state.copyWith(status: FeedStatus.populated, feed: feed));

      if (!hasMore) add(const FeedRecommenedPostsPageRequested());
    } catch (e, stack) {
      addError(e, stack);
      emit(state.copyWith(status: FeedStatus.failure));
    }
  }

  Future<void> _onRefreshRequested(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading));
    try {
      const page = 0;
      final posts = await _postsRepository.getPage(
        offset: page * _pageLimit,
        limit: _pageLimit,
      );
      final postLikersFutures = posts.map(
        (post) => _postsRepository.getPostLikersInFollowings(postId: post.id),
      );
      final postLikers = await Future.wait(postLikersFutures);

      final hasMore = posts.length >= _pageLimit;
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

      final feed = FeedPage(
        feed: Feed(blocks: blocks, totalBlocks: blocks.length),
        page: page + 1,
        hasMore: hasMore,
      );

      emit(state.copyWith(status: FeedStatus.populated, feed: feed));

      if (!hasMore) add(const FeedRecommenedPostsPageRequested());
    } catch (e, stack) {
      addError(e, stack);
      emit(state.copyWith(status: FeedStatus.failure));
    }
  }

  Future<void> _onPostLiked(
    FeedLikePostRequested event,
    Emitter<FeedState> emit,
  ) =>
      _postsRepository.like(
        userId: _currentUserId,
        id: event.postId,
      );

  Future<void> _onFollow(
    FeedPostAuthorFollowRequested event,
    Emitter<FeedState> emit,
  ) =>
      _userRepository.follow(
        followerId: _currentUserId,
        followToId: event.author,
      );

  Future<void> _onFeedPostShareRequested(
    FeedPostShareRequested event,
    Emitter<FeedState> emit,
  ) =>
      _postsRepository.sharePost(
        id: event.postId,
        sender: event.sender,
        receiver: event.receiver,
        message: event.message,
        postAuthor: event.postAuthor,
      );

  Future<PostBlock?> getPostBy(String id) async {
    final post = await _postsRepository.getPostBy(id: id);
    return post?.toPostLargeBlock();
  }

  Future<void> _onFeedRecommenedPostsPageRequested(
    FeedRecommenedPostsPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading));
    try {
      final recommenedBlocks = <InstaBlock>[..._recommenedPosts..shuffle()];
      final blocks = insertSponsoredBlocks(
        hasMore: true,
        blocks: recommenedBlocks,
        page: 0,
      );

      final feed = state.feed.copyWith(
        page: state.feed.page,
        hasMore: state.feed.hasMore,
        feed: state.feed.feed.copyWith(
          blocks: [...state.feed.feed.blocks, ...blocks],
          totalBlocks: state.feed.feed.totalBlocks + blocks.length,
        ),
      );

      emit(state.copyWith(feed: feed, status: FeedStatus.populated));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: FeedStatus.failure));
    }
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
          username: author.username,
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
          username: author.username,
        ),
        createdAt: createdAt,
        media: media,
        caption: caption,
        action: NavigateToPostAuthorProfileAction(authorId: author.id),
      );
}
