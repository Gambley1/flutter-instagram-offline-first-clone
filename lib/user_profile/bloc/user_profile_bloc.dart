import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc({
    required UserRepository userRepository,
    required PostsRepository postsRepository,
    String? userId,
  })  : _userRepository = userRepository,
        _postsRepository = postsRepository,
        _userId = userId ?? userRepository.currentUserId ?? '',
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
    on<UserProfileFetchFollowersRequested>(_onFollowersFetch);
    on<UserProfileFetchFollowingsRequested>(_onFollowingsFetch);
    on<UserProfileFollowersSubscriptionRequested>(
      _onFollowersSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<UserProfileFollowingsSubscriptionRequested>(
      _onFollowingsSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<UserProfileFollowUserRequested>(_onFollowUser);
    on<UserProfileRemoveFollowerRequested>(
      _onUserProfileRemoveFollowerRequested,
    );
  }

  Future<void> _onUserProfileSubscriptionRequested(
    UserProfileSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      isOwner ? _userRepository.user : _userRepository.profile(id: _userId),
      onData: (user) =>
          state.copyWith(user: user, status: UserProfileStatus.userUpdated),
    );
  }

  Future<void> _onUserProfilePostsCountSubscriptionRequested(
    UserProfilePostsCountSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.postsAmountOf(userId: _userId),
      onData: (postsCount) => state.copyWith(postsCount: postsCount),
    );
  }

  Future<void> _onUserProfileFollowingsCountSubscriptionRequested(
    UserProfileFollowingsCountSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _userRepository.followingsCountOf(userId: _userId),
      onData: (followingsCount) =>
          state.copyWith(followingsCount: followingsCount),
    );
  }

  Future<void> _onUserProfileFollowersCountSubscriptionRequested(
    UserProfileFollowersCountSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _userRepository.followersCountOf(userId: _userId),
      onData: (followersCount) =>
          state.copyWith(followersCount: followersCount),
    );
  }

  final String _userId;
  final UserRepository _userRepository;
  final PostsRepository _postsRepository;

  bool get isOwner => _userId == _userRepository.currentUserId;

  Stream<List<PostBlock>> userPosts({bool small = true}) {
    if (small) {
      return _postsRepository
          .postsOf(userId: _userId)
          .map((posts) => posts.map((e) => e.toPostSmallBlock).toList());
    }
    return _postsRepository.postsOf(userId: _userId).asyncMap((posts) async {
      final postLikersFutures = posts.map(
        (post) => _postsRepository.getPostLikersInFollowings(postId: post.id),
      );
      final postLikers = await Future.wait(postLikersFutures);
      final blocks = List<PostLargeBlock>.generate(posts.length, (index) {
        final likersInFollowings = postLikers[index];
        final post = posts[index]
            .toPostLargeBlock(likersInFollowings: likersInFollowings);
        return post;
      });
      return blocks;
    });
  }

  Stream<bool> followingStatus({String? followerId}) =>
      _userRepository.followingStatus(userId: _userId).asBroadcastStream();

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
      addError(error, stackTrace);
      emit(state.copyWith(status: UserProfileStatus.userUpdateFailed));
    }
  }

  Future<void> _onFollowersFetch(
    UserProfileFetchFollowersRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      final followers = await _userRepository.getFollowers(userId: _userId);
      emit(state.copyWith(followers: followers));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  Future<void> _onFollowingsFetch(
    UserProfileFetchFollowingsRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      final followings = await _userRepository.getFollowings(userId: _userId);
      emit(state.copyWith(followings: followings));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  Future<void> _onFollowersSubscriptionRequested(
    UserProfileFollowersSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _userRepository.streamFollowers(userId: _userId),
      onData: (followers) => state.copyWith(followers: followers),
    );
  }

  Future<void> _onFollowingsSubscriptionRequested(
    UserProfileFollowingsSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    await emit.forEach(
      _userRepository.streamFollowings(userId: _userId),
      onData: (followings) => state.copyWith(followings: followings),
    );
  }

  Future<void> _onFollowUser(
    UserProfileFollowUserRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await _userRepository.follow(followToId: event.userId ?? _userId);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  Future<void> _onUserProfileRemoveFollowerRequested(
    UserProfileRemoveFollowerRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await _userRepository.removeFollower(id: event.userId ?? _userId);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }
}
