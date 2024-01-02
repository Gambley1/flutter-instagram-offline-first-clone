// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

/// {@template authentication_user}
/// User model
///
/// [AuthenticationUser.anonymous] represents an unauthenticated user.
/// {@endtemplate}
class AuthenticationUser extends Equatable {
  /// {@macro authentication_user}
  const AuthenticationUser({
    required this.id,
    this.email,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.pushToken,
    this.isNewUser = true,
  });

  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String? username;

  /// The current user's full name.
  final String? fullName;

  /// Url for the current user's avatar url.
  final String? avatarUrl;

  /// The FCM notification push token.
  final String? pushToken;

  /// Whether the current user is a first time user.
  final bool isNewUser;

  /// Whether the current user is anonymous.
  bool get isAnonymous => this == anonymous;

  /// Anonymous user which represents an unauthenticated user.
  static const anonymous = AuthenticationUser(id: '');

  @override
  List<Object?> get props => [
        email,
        id,
        username,
        fullName,
        avatarUrl,
        isNewUser,
        pushToken,
      ];
}
