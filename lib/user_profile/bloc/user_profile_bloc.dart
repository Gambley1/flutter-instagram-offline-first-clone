import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'user_profile_event.dart';
part 'user_profle_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc({
    required UserRepository userRepository,
    required PostsRepository postsRepository,
    String? userId,
  })  : _userRepository = userRepository,
        _postsRepository = postsRepository,
        _userId = userId,
        super(const UserProfileState.initial()) {
    on<UserProfileSubscriptionRequested>(
      _onUserProfileSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<UserProfilePostsCountSubscriptionRequested>(
      _onUserProfilePostsCountSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<UserProfileFollowingsCountSubscriptionRequested>(
      _onUserProfileFollowingsCountSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<UserProfileFollowersCountSubscriptionRequested>(
      _onUserProfileFollowersCountSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<UserProfileUpdateRequested>(_onUserProfileUpdateRequested);
    on<UserProfilePostCreateRequested>(_onCreatePost);
    on<UserProfileDeletePostRequested>(_onDeletePost);
    on<UserProfileFetchFollowersRequested>(_onFollowersFetch);
    on<UserProfileFetchFollowingsRequested>(_onFollowingsFetch);
    on<UserProfileFollowingsSubscriptionRequested>(
      _onFollowingsSubscriptionRequested,
    );
    on<UserProfileFollowUserRequested>(_onFollowUser);
  }

  Future<void> _onUserProfileSubscriptionRequested(
    UserProfileSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    if (_userId == _currentUserId) {
      await emit.forEach(
        _userRepository.user,
        onData: (user) =>
            state.copyWith(user: user, status: UserProfileStatus.userUpdated),
      );
    } else {
      await emit.forEach(
        _userRepository.profile(id: _userId ?? event.userId!),
        onData: (user) =>
            state.copyWith(user: user, status: UserProfileStatus.userUpdated),
      );
    }
  }

  Future<void> _onUserProfilePostsCountSubscriptionRequested(
    UserProfilePostsCountSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.postsAmountOf(userId: _userId ?? _currentUserId!),
      onData: (postsCount) => state.copyWith(postsCount: postsCount),
    );
  }

  Future<void> _onUserProfileFollowingsCountSubscriptionRequested(
    UserProfileFollowingsCountSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _userRepository.followingsCountOf(userId: _userId ?? _currentUserId!),
      onData: (followingsCount) =>
          state.copyWith(followingsCount: followingsCount),
    );
  }

  Future<void> _onUserProfileFollowersCountSubscriptionRequested(
    UserProfileFollowersCountSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _userRepository.followersCountOf(userId: _userId ?? _currentUserId!),
      onData: (followersCount) =>
          state.copyWith(followersCount: followersCount),
    );
  }

  final String? _userId;
  final UserRepository _userRepository;
  final PostsRepository _postsRepository;

  late final _currentUserId = _userRepository.currentUserId;

  bool get isOwner {
    if (_userId == _currentUserId) return true;
    return false;
  }

  Stream<List<PostBlock>> userPosts({
    String? userId,
    bool small = true,
  }) async* {
    if (small) {
      yield* _postsRepository
          .postsOf(userId: userId ?? _userId)
          .map((posts) => posts.map((e) => e.toPostSmallBlock).toList());
    } else {
      yield* _postsRepository
          .postsOf(userId: userId ?? _userId)
          .asyncMap((posts) async {
        final postLikersFutures = posts.map(
          (post) => _postsRepository.getPostLikersInFollowings(postId: post.id),
        );
        final postLikers = await Future.wait(postLikersFutures);
        final blocks = List<InstaBlock>.generate(posts.length, (index) {
          final likersInFollowings = postLikers[index];
          final post = posts[index]
              .toPostLargeBlock(likersInFollowings: likersInFollowings);
          return post;
        });
        return blocks;
      }).map((blocks) => blocks.toList().cast<PostBlock>());
    }
  }

  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  }) =>
      _userRepository
          .followingStatus(
            followerId: followerId ?? _currentUserId!,
            userId: userId,
          )
          .asBroadcastStream();

  Future<void> _onUserProfileUpdateRequested(
    UserProfileUpdateRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await _userRepository.updateUser(
        email: event.email,
        username: event.username,
        avatarUrl: event.avatarUrl,
        fullName: event.fullName,
        pushToken: event.pushToken,
      );
      emit(state.copyWith(status: UserProfileStatus.userUpdated));
    } catch (error, stackTrace) {
      logE('Failed to update user.', error: error, stackTrace: stackTrace);
      addError(error, stackTrace);
      emit(state.copyWith(status: UserProfileStatus.userUpdateFailed));
    }
  }

  Future<void> _onCreatePost(
    UserProfilePostCreateRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await _postsRepository.createPost(
      id: event.postId,
      userId: event.userId,
      caption: event.caption,
      media: json.encode(event.media),
    );
  }

  Future<void> _onDeletePost(
    UserProfileDeletePostRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    final postId = event.postId;
    final deletedId = await _postsRepository.deletePost(id: postId);
    event.onPostDeleted?.call(deletedId);
  }

  Future<void> _onFollowersFetch(
    UserProfileFetchFollowersRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    final followers = await _userRepository.getFollowers(
      userId: _userId ?? _currentUserId!,
    );
    emit(state.copyWith(followers: followers));
  }

  Future<void> _onFollowingsFetch(
    UserProfileFetchFollowingsRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    final followings = await _userRepository.getFollowings(
      userId: _userId ?? _currentUserId!,
    );
    emit(state.copyWith(followings: followings));
  }

  Future<void> _onFollowingsSubscriptionRequested(
    UserProfileFollowingsSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _userRepository.streamFollowings(userId: _userId ?? _currentUserId!),
      onData: (followings) => state.copyWith(followings: followings),
    );
  }

  Future<void> _onFollowUser(
    UserProfileFollowUserRequested event,
    Emitter<UserProfileState> emit,
  ) =>
      _userRepository.follow(
        followerId: _currentUserId!,
        followToId: event.userId,
      );
}
