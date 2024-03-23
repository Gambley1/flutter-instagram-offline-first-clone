import 'package:authentication_client/authentication_client.dart';
import 'package:shared/shared.dart';

/// {@template user}
/// User model represents the current user.
/// {@endtemplate}
class User extends AuthenticationUser {
  /// {@macro user}
  const User({
    required super.id,
    super.email,
    super.username,
    super.fullName,
    super.avatarUrl,
    super.pushToken,
    super.isNewUser,
  });

  /// Converts an [AuthenticationUser] instance to [User].
  factory User.fromAuthenticationUser({
    required AuthenticationUser authenticationUser,
  }) =>
      User(
        email: authenticationUser.email,
        id: authenticationUser.id,
        username: authenticationUser.username,
        fullName: authenticationUser.fullName,
        avatarUrl: authenticationUser.avatarUrl,
        pushToken: authenticationUser.pushToken,
        isNewUser: authenticationUser.isNewUser,
      );

  /// Converts a `Map<String, dynamic>` json to a [User] instance.
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['user_id'] as String? ?? json['id'] as String,
        email: json['email'] as String?,
        username: json['username'] as String?,
        fullName: json['full_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        pushToken: json['push_token'] as String?,
        isNewUser: false,
      );

  /// Converts a `Map<String, dynamic>` to a [User] instance.
  factory User.fromParticipant(Map<String, dynamic> participant) => User(
        id: participant['participant_id'] as String,
        avatarUrl: participant['participant_avatar_url'] as String?,
        fullName: participant['participant_name'] as String?,
        email: participant['participant_email'] as String?,
        username: participant['participant_username'] as String?,
        pushToken: participant['participant_push_token'] as String?,
      );

  /// Whether the current user is anonymous.
  @override
  bool get isAnonymous => this == anonymous;

  /// Anonymous user which represents an unauthenticated user.
  static const User anonymous = User(id: '');

  /// The effective full name display without null aware operators.
  /// By default no existing name value is `Unknown`.
  String get displayFullName => fullName ?? username ?? 'Unknown';

  /// The effective user name display without null aware operators.
  /// By default no existing name value is `Unknown`.
  String get displayUsername => username ?? fullName ?? 'Unknown';

  /// Converts current [User] instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (email != null) 'email': email,
      'user_id': id,
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (pushToken != null) 'push_token': pushToken,
      'is_new_user': isNewUser,
    };
  }
}

/// Extension that converts [PostAuthor] into [User] instance.
extension UserX on PostAuthor {
  /// Converts a [PostAuthor] into a [User] instance.
  User get toUser => User(
        id: id,
        avatarUrl: avatarUrl,
        username: username,
      );
}
