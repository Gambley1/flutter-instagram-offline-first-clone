import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required PostsRepository postsRepository,
    required UserRepository userRepository,
  })  : _postsRepository = postsRepository,
        _userRepository = userRepository,
        super(const FeedState.initial()) {
    on<FeedPageRequested>(_onPageRequested);
    on<FeedRefreshRequested>(_onRefreshRequested);
    on<FeedLikePostRequested>(_onPostLiked);
    on<FeedPostAuthorFollowRequested>(_onFollow);
    on<FeedPostShareRequested>(_onFeedPostShareRequested);
  }

  static const _pageLimit = 10;

  final PostsRepository _postsRepository;
  final UserRepository _userRepository;

  String get _currentUserId => _userRepository.currentUserId!;

  bool isOwnerOfPostBy(String authorId) =>
      _userRepository.isOwnerOfPostBy(authorId: authorId);

  Stream<bool> isLiked(String id) => _postsRepository
      .isLiked(
        userId: _currentUserId,
        id: id,
      )
      .asBroadcastStream();

  Stream<int> likesCount(String id) => _postsRepository.likesOf(id: id);

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

  static final _mySponsoredBlocks = <InstaBlock>[
    PostSponsoredBlock(
      id: 'b6faca71-061c-4f05-93f0-d164baacca3d',
      author: const PostAuthor.confirmed(),
      publishedAt: DateTime(2023, 11, 09),
      imageUrl:
          'https://blog.nursing.com/hs-fs/hubfs/visual%20nursing%20app.webp?width=1080&height=1080&name=visual%20nursing%20app.webp',
      caption: 'Hello world, this is a sponsored block #1',
      action: const NavigateToSponsoredPostAuthorProfileAction(
        authorId: '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        promoPreviewImageUrl:
            'https://instagram.fala5-2.fna.fbcdn.net/v/t51.2885-19/349043288_799972341566680_146016102643359969_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fala5-2.fna.fbcdn.net&_nc_cat=104&_nc_ohc=sEVHyymBefkAX9i3zYg&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfBiQuXJ5iIIVb8qP-_RfY8a6gADNgP_PLsQEhqdhM8DRA&oe=6552BA94&_nc_sid=8b3546',
        promoUrl: 'https://www.instagram.com/zulu_em/',
      ),
      imagesUrl: [
        'https://blog.nursing.com/hs-fs/hubfs/visual%20nursing%20app.webp?width=1080&height=1080&name=visual%20nursing%20app.webp',
      ],
    ),
    PostSponsoredBlock(
      id: '0bcf4fa1-2a58-4809-b07b-5654e32e6fc2',
      author: const PostAuthor.confirmed(),
      publishedAt: DateTime(2023, 11, 09),
      imageUrl:
          'https://images.squarespace-cdn.com/content/v1/54222358e4b0ef23d87a996b/1659992618857-S3ZIJIAT0V659W9HFTEF/3.png',
      caption: 'Hello world, this is a sponsored block #2',
      action: const NavigateToSponsoredPostAuthorProfileAction(
        authorId: '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        promoPreviewImageUrl:
            'https://instagram.fala5-2.fna.fbcdn.net/v/t51.2885-19/349043288_799972341566680_146016102643359969_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fala5-2.fna.fbcdn.net&_nc_cat=104&_nc_ohc=sEVHyymBefkAX9i3zYg&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfBiQuXJ5iIIVb8qP-_RfY8a6gADNgP_PLsQEhqdhM8DRA&oe=6552BA94&_nc_sid=8b3546',
        promoUrl: 'https://www.instagram.com/zulu_em/',
      ),
      imagesUrl: [
        'https://images.squarespace-cdn.com/content/v1/54222358e4b0ef23d87a996b/1659992618857-S3ZIJIAT0V659W9HFTEF/3.png',
      ],
    ),
    PostSponsoredBlock(
      id: '4071ae1f-7e64-43d7-9763-4ced3b84dcfc',
      author: const PostAuthor.confirmed(),
      publishedAt: DateTime(2023, 11, 09),
      imageUrl:
          'https://global.discourse-cdn.com/business7/uploads/adalo/original/2X/b/bc2fa4e8174f0b997c0a0f4167fe6895ae3092c4.jpeg',
      caption: 'Hello world, this is a sponsored block #3',
      action: const NavigateToSponsoredPostAuthorProfileAction(
        authorId: '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        promoPreviewImageUrl:
            'https://instagram.fala5-2.fna.fbcdn.net/v/t51.2885-19/349043288_799972341566680_146016102643359969_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fala5-2.fna.fbcdn.net&_nc_cat=104&_nc_ohc=sEVHyymBefkAX9i3zYg&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfBiQuXJ5iIIVb8qP-_RfY8a6gADNgP_PLsQEhqdhM8DRA&oe=6552BA94&_nc_sid=8b3546',
        promoUrl: 'https://www.instagram.com/zulu_em/',
      ),
      imagesUrl: [
        'https://global.discourse-cdn.com/business7/uploads/adalo/original/2X/b/bc2fa4e8174f0b997c0a0f4167fe6895ae3092c4.jpeg',
      ],
    ),
    PostSponsoredBlock(
      id: '4f6a8b3f-07f6-4b33-a9fe-2420f750fe31',
      author: const PostAuthor.confirmed(),
      publishedAt: DateTime(2023, 11, 09),
      imageUrl:
          'https://images.squarespace-cdn.com/content/v1/54222358e4b0ef23d87a996b/1659992618857-S3ZIJIAT0V659W9HFTEF/3.png',
      caption: 'Hello world, this is a sponsored block #4',
      action: const NavigateToSponsoredPostAuthorProfileAction(
        authorId: '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
        promoPreviewImageUrl:
            'https://instagram.fala5-2.fna.fbcdn.net/v/t51.2885-19/349043288_799972341566680_146016102643359969_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fala5-2.fna.fbcdn.net&_nc_cat=104&_nc_ohc=sEVHyymBefkAX9i3zYg&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfBiQuXJ5iIIVb8qP-_RfY8a6gADNgP_PLsQEhqdhM8DRA&oe=6552BA94&_nc_sid=8b3546',
        promoUrl: 'https://www.instagram.com/zulu_em/',
      ),
      imagesUrl: [
        'https://images.squarespace-cdn.com/content/v1/54222358e4b0ef23d87a996b/1659992618857-S3ZIJIAT0V659W9HFTEF/3.png',
      ],
    ),
  ];

  List<InstaBlock> insertSponsoredBlocks({
    required bool hasMore,
    required List<InstaBlock> blocks,
    required int page,
    List<InstaBlock>? sponsoredBlocks,
  }) {
    final random = Random();

    final sponsored = sponsoredBlocks ?? _mySponsoredBlocks;
    var tempBlocks = [...blocks];
    var tempDataLength = tempBlocks.length;

    final skipRange = [1, 2, 3];
    var previosSkipRangeIs1 = false;

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
        if (blocks.isNotEmpty) const DividerHorizontalBlock(),
        const SectionHeaderBlock(
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

      final newPage = currentPage + 1;

      final hasMore = posts.length >= _pageLimit;
      final instaBlocks = <InstaBlock>[];

      for (final post in posts) {
        instaBlocks.add(post.toPostLargeBlock);
      }
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

      final hasMore = posts.length >= _pageLimit;
      final instaBlocks = <InstaBlock>[];

      for (final post in posts) {
        instaBlocks.add(post.toPostLargeBlock);
      }
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
    return post?.toPostLargeBlock;
  }
}

extension PostX on Post {
  /// Converts [Post] instance into [PostLargeBlock] instance.
  PostLargeBlock get toPostLargeBlock => PostLargeBlock(
        id: id,
        author: PostAuthor.confirmed(
          id: author,
          avatarUrl: avatarUrl,
          username: username,
        ),
        publishedAt: publishedAt,
        imageUrl: mediaUrl,
        imagesUrl: imagesUrl,
        caption: caption,
        action: NavigateToPostAuthorProfileAction(authorId: author),
      );

  /// Converts [Post] instance into [PostSmallBlock] instance.
  PostSmallBlock get toPostSmallBlock => PostSmallBlock(
        id: id,
        author: PostAuthor.confirmed(
          id: author,
          avatarUrl: avatarUrl,
          username: username,
        ),
        publishedAt: publishedAt,
        imageUrl: mediaUrl,
        imagesUrl: imagesUrl,
        caption: caption,
        action: NavigateToPostAuthorProfileAction(authorId: author),
      );
}
