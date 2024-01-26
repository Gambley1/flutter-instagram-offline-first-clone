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
    on<UserProfileUpdated>(_onAccountProfileUpdated);
    on<UserProfileUpdateRequested>(_onUserProfileUpdate);
    on<UserProfilePostsRequested>(_onPostsFetch);
    on<UserProfilePostCreateRequested>(_onCreatePost);
    on<UserProfileLikePostRequested>(_onLikePost);
    on<UserProfileDeletePostRequested>(_onDeletePost);
    on<UserProfileFetchFollowersRequested>(_onFollowersFetch);
    on<UserProfileFetchFollowingsRequested>(_onFollowingsFetch);
    on<UserProfileFollowingsSubscriptionRequested>(
      _onFollowingsSubscriptionRequested,
    );
    on<UserProfileFollowUserRequested>(_onFollowUser);

    _userSubscription =
        userRepository.user.listen(_userChanged, onError: addError);
  }

  void _userChanged(User user) => add(UserProfileUpdated(user));

  void _onAccountProfileUpdated(
    UserProfileUpdated event,
    Emitter<UserProfileState> emit,
  ) =>
      emit(
        state.copyWith(
          user: event.user,
          status: UserProfileStatus.userUpdated,
        ),
      );

  final String? _userId;
  final UserRepository _userRepository;
  final PostsRepository _postsRepository;

  bool isOwnerOfPostBy(String authorId) =>
      _userRepository.isOwnerOfPostBy(authorId: authorId);

  StreamSubscription<dynamic>? _userSubscription;

  late final _currentUserId = _userRepository.currentUserId;

  bool get isOwner {
    if (_userId == null) return true;
    if (_userId == _currentUserId) return true;
    return false;
  }

  Stream<List<PostBlock>> userPosts({bool small = true}) async* {
    if (small) {
      yield* _postsRepository
          .postsOf(
            currentUserId: _currentUserId!,
            userId: _userId,
          )
          .map((posts) => posts.map((e) => e.toPostSmallBlock).toList())
          .asBroadcastStream();
    } else {
      yield* _postsRepository
          .postsOf(
            currentUserId: _currentUserId!,
            userId: _userId,
          )
          .asyncMap((posts) async {
            final postLikersFutures = posts.map(
              (post) =>
                  _postsRepository.getPostLikersInFollowings(postId: post.id),
            );
            final postLikers = await Future.wait(postLikersFutures);
            final blocks = List<InstaBlock>.generate(posts.length, (index) {
              final likersInFollowings = postLikers[index];
              final post = posts[index]
                  .toPostLargeBlock(likersInFollowings: likersInFollowings);
              return post;
            });
            return blocks;
          })
          .map((blocks) => blocks.toList().cast<PostBlock>())
          .asBroadcastStream();
    }
  }

  Stream<int> postsAmountOf() => _postsRepository.postsAmountOf(
        userId: _userId ?? _currentUserId!,
      );

  Stream<int> likesCount(String postId) =>
      _postsRepository.likesOf(id: postId).asBroadcastStream();

  Stream<bool> isLiked(String postId) => _postsRepository
      .isLiked(
        id: postId,
        userId: _currentUserId!,
      )
      .asBroadcastStream();

  Stream<int> followersCountOf() => _userRepository.followersCountOf(
        userId: _userId ?? _currentUserId!,
      );

  Stream<int> followingsCountOf({String? userId}) =>
      _userRepository.followingsCountOf(
        userId: _userId ?? _currentUserId!,
      );

  Future<bool> isFollowed({String? followerId}) => _userRepository.isFollowed(
        followerId: followerId ?? _currentUserId!,
        userId: _userId!,
      );

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

  Future<void> _onUserProfileUpdate(
    UserProfileUpdateRequested event,
    Emitter<UserProfileState> emit,
  ) =>
      _userRepository.updateUser(
        email: event.email,
        username: event.username,
        avatarUrl: event.avatarUrl,
        fullName: event.fullName,
        pushToken: event.pushToken,
      );

  Future<void> _onPostsFetch(
    UserProfilePostsRequested event,
    Emitter<UserProfileState> emit,
  ) async {}

  Future<void> _onLikePost(
    UserProfileLikePostRequested event,
    Emitter<UserProfileState> emit,
  ) =>
      _postsRepository.like(
        id: event.postId,
        userId: _currentUserId!,
      );

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
    // final followings = await _userRepository.getFollowings(
    //   userId: _userId ?? _currentUserId!,
    // );
    // emit(state.copyWith(followings: followings));
  }

  Future<void> _onFollowUser(
    UserProfileFollowUserRequested event,
    Emitter<UserProfileState> emit,
  ) =>
      _userRepository.follow(
        followerId: _currentUserId!,
        followToId: event.userId,
      );

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
