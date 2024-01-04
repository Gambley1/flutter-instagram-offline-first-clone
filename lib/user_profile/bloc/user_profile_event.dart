// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'user_profile_bloc.dart';

sealed class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

class UserProfileUpdated extends UserProfileEvent {
  const UserProfileUpdated(this.user) : super();

  final User user;

  @override
  List<Object> get props => [user];
}

final class ProfileFetch extends UserProfileEvent {
  const ProfileFetch({this.id});

  final String? id;
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

final class UserProfilePostsRequested extends UserProfileEvent {
  const UserProfilePostsRequested();
}

final class UserProfilePostCreateRequested extends UserProfileEvent {
  const UserProfilePostCreateRequested({
    required this.postId,
    required this.userId,
    required this.caption,
    required this.type,
    required this.mediaUrl,
    required this.imagesUrl,
  });

  final String postId;
  final String userId;
  final String caption;
  final String type;
  final String mediaUrl;
  final String imagesUrl;
}

sealed class _PostEvent extends UserProfileEvent {
  const _PostEvent(this.postId);

  final String postId;
}

final class UserProfileLikePostRequested extends _PostEvent {
  const UserProfileLikePostRequested(super.postId);
}

final class UserProfileDeletePostRequested extends _PostEvent {
  const UserProfileDeletePostRequested(super.postId);
}

final class UserProfileFollowersRequested extends UserProfileEvent {
  const UserProfileFollowersRequested({this.userId});

  final String? userId;
}

final class UserProfileFollowingsRequested extends UserProfileEvent {
  const UserProfileFollowingsRequested({this.userId});

  final String? userId;
}

final class UserProfileFollowUserRequested extends UserProfileEvent {
  const UserProfileFollowUserRequested(this.userId);

  final String userId;
}
