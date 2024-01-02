// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:authentication_client/authentication_client.dart';

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

  /// Converts an [AuthenticationUser] isntace to [User].
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

  /// Converts a `Map<String, dynamic>` row to a [User] instance.
  factory User.fromRow(Map<String, dynamic> row) => User(
        email: row['email'] as String?,
        id: row['id'] as String,
        username: row['username'] as String?,
        fullName: row['full_name'] as String?,
        avatarUrl: row['avatar_url'] as String?,
        pushToken: row['push_token'] as String?,
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

  /// Converts current [User] instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'push_token': pushToken,
      'is_new_user': isNewUser,
    };
  }

  /// Converts current [User] instance to a `JSON` string.
  String toJson() => json.encode(toMap());
}
