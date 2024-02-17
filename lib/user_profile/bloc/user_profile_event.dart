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

final class UserProfilePostCreateRequested extends UserProfileEvent {
  const UserProfilePostCreateRequested({
    required this.postId,
    required this.userId,
    required this.caption,
    required this.media,
  });

  final String postId;
  final String userId;
  final String caption;
  final List<Map<String, dynamic>> media;
}

sealed class _PostEvent extends UserProfileEvent {
  const _PostEvent(this.postId);

  final String postId;
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

final class UserProfileLikePostRequested extends _PostEvent {
  const UserProfileLikePostRequested(super.postId);
}

final class UserProfileDeletePostRequested extends _PostEvent {
  const UserProfileDeletePostRequested(super.postId, {this.onPostDeleted});

  final ValueSetter<String?>? onPostDeleted;
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
  const UserProfileFollowersSubscriptionRequested({this.userId});

  final String? userId;
}

final class UserProfileFollowingsSubscriptionRequested
    extends UserProfileEvent {
  const UserProfileFollowingsSubscriptionRequested({this.userId});

  final String? userId;
}

final class UserProfileFollowUserRequested extends UserProfileEvent {
  const UserProfileFollowUserRequested(this.userId);

  final String userId;
}

final class UserProfileRemoveFollowerRequested extends UserProfileEvent {
  const UserProfileRemoveFollowerRequested(this.userId);

  final String userId;
}
