// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'user_profile_bloc.dart';

enum UserProfileStatus {
  initial,
  fetchingNotificationsEnabled,
  fetchingNotificationsEnabledFailed,
  fetchingNotificationsEnabledSucceeded,
  togglingNotifications,
  togglingNotificationsFailed,
  togglingNotificationsSucceeded,
  userUpdated,
  userUpdateFailed,
}

class UserProfileState extends Equatable {
  const UserProfileState._({
    required this.status,
    required this.user,
    required this.posts,
    required this.followings,
    required this.followers,
    required this.postsCount,
    required this.followingsCount,
    required this.followersCount,
  });

  const UserProfileState.initial()
      : this._(
          status: UserProfileStatus.initial,
          user: User.anonymous,
          posts: const [],
          followers: const [],
          followings: const [],
          postsCount: 0,
          followersCount: 0,
          followingsCount: 0,
        );

  final UserProfileStatus status;
  final User user;
  final List<PostBlock> posts;
  final List<User> followings;
  final List<User> followers;
  final int postsCount;
  final int followingsCount;
  final int followersCount;

  @override
  List<Object> get props => [
        status,
        user,
        posts,
        followings,
        followers,
        postsCount,
        followingsCount,
        followersCount,
      ];

  UserProfileState copyWith({
    UserProfileStatus? status,
    User? user,
    List<PostBlock>? posts,
    List<User>? followings,
    List<User>? followers,
    int? postsCount,
    int? followingsCount,
    int? followersCount,
  }) {
    return UserProfileState._(
      status: status ?? this.status,
      user: user ?? this.user,
      posts: posts ?? this.posts,
      followings: followings ?? this.followings,
      followers: followers ?? this.followers,
      postsCount: postsCount ?? this.postsCount,
      followingsCount: followingsCount ?? this.followingsCount,
      followersCount: followersCount ?? this.followersCount,
    );
  }
}
