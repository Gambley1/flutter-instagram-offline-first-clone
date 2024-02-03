import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'reel_bloc.g.dart';
part 'reel_event.dart';
part 'reel_state.dart';

class ReelBloc extends HydratedBloc<ReelEvent, ReelState> {
  ReelBloc({
    required String reelId,
    required PostsRepository postsRepository,
    required UserRepository userRepository,
  })  : _reelId = reelId,
        _postsRepository = postsRepository,
        _userRepository = userRepository,
        super(const ReelState.intital()) {
    on<ReelLikesCountSubscriptionRequested>(
      _onReelLikesCountSubscriptionRequested,
      transformer: droppable(),
    );
    on<ReelCommentsCountSubscriptionRequested>(
      _onReelCommentsCountSubscriptionRequested,
      transformer: droppable(),
    );
    on<ReelIsLikedSubscriptionRequested>(
      _onReelIsLikedSubscriptionRequested,
      transformer: droppable(),
    );
    on<ReelAuthoFollowingStatusSubscriptionRequested>(
      _onReelAuthorFollowingStatusSubscriptionRequested,
      transformer: droppable(),
    );
    on<ReelLikersPageRequested>(
      _onReelLikersPageRequested,
      transformer: throttleDroppable(),
    );
    on<ReelLikeRequested>(_onReelLikeRequested);
    on<ReelAuthorSubscribeRequested>(_onReelAuthorSubscribeRequested);
    on<ReelDeleteRequested>(_onReelDeleteRequested);
  }

  static const _usersLimit = 100;

  final UserRepository _userRepository;
  final PostsRepository _postsRepository;

  final String _reelId;

  @override
  String get id => _reelId;

  Future<void> _onReelLikesCountSubscriptionRequested(
    ReelLikesCountSubscriptionRequested event,
    Emitter<ReelState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.likesOf(id: _reelId),
      onData: (likesCount) => state.copyWith(likes: likesCount),
    );
  }

  Future<void> _onReelCommentsCountSubscriptionRequested(
    ReelCommentsCountSubscriptionRequested event,
    Emitter<ReelState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.commentsAmountOf(postId: _reelId),
      onData: (commentsCount) => state.copyWith(commentsCount: commentsCount),
    );
  }

  Future<void> _onReelIsLikedSubscriptionRequested(
    ReelIsLikedSubscriptionRequested event,
    Emitter<ReelState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.isLiked(userId: event.currentUserId, id: _reelId),
      onData: (isLiked) => state.copyWith(isLiked: isLiked),
    );
  }

  Future<void> _onReelAuthorFollowingStatusSubscriptionRequested(
    ReelAuthoFollowingStatusSubscriptionRequested event,
    Emitter<ReelState> emit,
  ) async {
    if (event.currentUserId == event.ownerId) {
      emit(state.copyWith(isOwner: true));
      return;
    }
    await emit.forEach(
      _userRepository.followingStatus(
        followerId: event.currentUserId,
        userId: event.ownerId,
      ),
      onData: (isSubscribed) =>
          state.copyWith(isFollowed: isSubscribed, isOwner: false),
    );
  }

  Future<void> _onReelLikersPageRequested(
    ReelLikersPageRequested event,
    Emitter<ReelState> emit,
  ) async {
    final page = event.page;
    emit(state.copyWith(status: ReelStatus.loading));
    try {
      final users = await _postsRepository.getPostLikers(
        postId: _reelId,
        offset: page * _usersLimit,
        limit: _usersLimit,
      );
      emit(state.copyWith(status: ReelStatus.success, likers: users));
    } catch (error, stackTrace) {
      logE(
        'Reel likers profiles page failed.',
        error: error,
        stackTrace: stackTrace,
      );
      addError(error, stackTrace);
      emit(state.copyWith(status: ReelStatus.failure));
    }
  }

  Future<void> _onReelLikeRequested(
    ReelLikeRequested event,
    Emitter<ReelState> emit,
  ) async {
    try {
      await _postsRepository.like(id: id, userId: event.userId);
      emit(state.copyWith(status: ReelStatus.success));
    } catch (error, stackTrace) {
      logE('Reel like failed.', error: error, stackTrace: stackTrace);
      addError(error, stackTrace);
      emit(state.copyWith(status: ReelStatus.failure));
    }
  }

  Future<void> _onReelAuthorSubscribeRequested(
    ReelAuthorSubscribeRequested event,
    Emitter<ReelState> emit,
  ) async {
    emit(state.copyWith(status: ReelStatus.loading));
    try {
      await _userRepository.follow(
        followerId: event.currentUserId,
        followToId: event.authorId,
      );
      emit(state.copyWith(status: ReelStatus.success));
    } catch (error, stackTrace) {
      logE(
        'Subscribe to reel author failed.',
        error: error,
        stackTrace: stackTrace,
      );
      addError(error, stackTrace);
      emit(state.copyWith(status: ReelStatus.failure));
    }
  }

  Future<void> _onReelDeleteRequested(
    ReelDeleteRequested event,
    Emitter<ReelState> emit,
  ) =>
      _postsRepository.deletePost(id: id);

  @override
  ReelState? fromJson(Map<String, dynamic> json) => ReelState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ReelState state) => state.toJson();
}

extension PostReelBlockConverter on Post {
  PostReelBlock get toPostReelBlock => PostReelBlock(
        id: id,
        author: PostAuthor.confirmed(
          id: author.id,
          avatarUrl: author.avatarUrl,
          username: author.username,
        ),
        createdAt: createdAt,
        media: media,
        caption: caption,
      );
}
