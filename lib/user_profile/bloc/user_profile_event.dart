// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'user_profile_bloc.dart';

sealed class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

final class UserProfileUpdateRequested extends UserProfileEvent {
  const UserProfileUpdateRequested({
    this.fullName,
    this.email,
    this.username,
    this.avatarUrl,
    this.pushToken,
  });

  final String? fullName;
  final String? email;
  final String? username;
  final String? avatarUrl;
  final String? pushToken;
}

final class UserProfileSubscriptionRequested extends UserProfileEvent {
  const UserProfileSubscriptionRequested({this.userId});

  final String? userId;
}

final class UserProfilePostsSubscriptionRequested extends UserProfileEvent {
  const UserProfilePostsSubscriptionRequested();
}

final class UserProfilePostsCountSubscriptionRequested
    extends UserProfileEvent {
  const UserProfilePostsCountSubscriptionRequested();
}

final class UserProfileFollowingsCountSubscriptionRequested
    extends UserProfileEvent {
  const UserProfileFollowingsCountSubscriptionRequested();
}

final class UserProfileFollowersCountSubscriptionRequested
    extends UserProfileEvent {
  const UserProfileFollowersCountSubscriptionRequested();
}

final class UserProfileFetchFollowersRequested extends UserProfileEvent {
  const UserProfileFetchFollowersRequested({this.userId});

  final String? userId;
}

final class UserProfileFetchFollowingsRequested extends UserProfileEvent {
  const UserProfileFetchFollowingsRequested({this.userId});

  final String? userId;
}

final class UserProfileFollowersSubscriptionRequested extends UserProfileEvent {
  const UserProfileFollowersSubscriptionRequested();
}

final class UserProfileFollowingsSubscriptionRequested
    extends UserProfileEvent {
  const UserProfileFollowingsSubscriptionRequested();
}

final class UserProfileFollowUserRequested extends UserProfileEvent {
  const UserProfileFollowUserRequested({this.userId});

  final String? userId;
}

final class UserProfileRemoveFollowerRequested extends UserProfileEvent {
  const UserProfileRemoveFollowerRequested({this.userId});

  final String? userId;
}
