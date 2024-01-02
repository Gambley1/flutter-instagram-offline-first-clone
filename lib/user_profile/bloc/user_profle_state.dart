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
}

class UserProfileState extends Equatable {
  const UserProfileState._({
    required this.user,
    required this.followings,
    required this.followers,
    required this.status,
  });

  const UserProfileState.initial()
      : this._(
          status: UserProfileStatus.initial,
          user: User.anonymous,
          followers: const [],
          followings: const [],
        );

  final UserProfileStatus status;
  final User user;
  final List<User> followings;
  final List<User> followers;

  @override
  List<Object> get props => [followings, followers, user, status];

  UserProfileState copyWith({
    UserProfileStatus? status,
    User? user,
    List<User>? followings,
    List<User>? followers,
  }) {
    return UserProfileState._(
      status: status ?? this.status,
      user: user ?? this.user,
      followings: followings ?? this.followings,
      followers: followers ?? this.followers,
    );
  }
}
