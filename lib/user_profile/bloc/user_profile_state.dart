part of 'user_profile_bloc.dart';

enum UserProfileStatus {
  initial,
  userUpdated,
  userUpdateFailed,
}

class UserProfileState extends Equatable {
  const UserProfileState._({
    required this.status,
    required this.user,
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
          followers: const [],
          followings: const [],
          postsCount: 0,
          followersCount: 0,
          followingsCount: 0,
        );

  final UserProfileStatus status;
  final User user;
  final List<User> followings;
  final List<User> followers;
  final int postsCount;
  final int followingsCount;
  final int followersCount;

  @override
  List<Object> get props => [
        status,
        user,
        followings,
        followers,
        postsCount,
        followingsCount,
        followersCount,
      ];

  UserProfileState copyWith({
    UserProfileStatus? status,
    User? user,
    List<User>? followings,
    List<User>? followers,
    int? postsCount,
    int? followingsCount,
    int? followersCount,
  }) {
    return UserProfileState._(
      status: status ?? this.status,
      user: user ?? this.user,
      followings: followings ?? this.followings,
      followers: followers ?? this.followers,
      postsCount: postsCount ?? this.postsCount,
      followingsCount: followingsCount ?? this.followingsCount,
      followersCount: followersCount ?? this.followersCount,
    );
  }
}
