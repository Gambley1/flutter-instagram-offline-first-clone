import 'dart:async';

import 'package:authentication_client/src/models/models.dart';

/// {@template authentication_exception}
/// Exceptions from the authentication client.
/// {@endtemplate}
abstract class AuthenticationException implements Exception {
  /// {@macro authentication_exception}
  const AuthenticationException(this.error);

  /// The error which was caught.
  final Object error;

  @override
  String toString() => 'Authentication exception error: $error';
}

/// {@template send_login_email_link_failure}
/// Thrown during the sending login email link process if a failure occurs.
/// {@endtemplate}
class SendLoginEmailLinkFailure extends AuthenticationException {
  /// {@macro send_login_email_link_failure}
  const SendLoginEmailLinkFailure(super.error);
}

/// {@template is_log_in_email_link_failure}
/// Thrown during the validation of the email link process if a failure occurs.
/// {@endtemplate}
class IsLogInWithEmailLinkFailure extends AuthenticationException {
  /// {@macro is_log_in_email_link_failure}
  const IsLogInWithEmailLinkFailure(super.error);
}

/// {@template log_in_with_email_link_failure}
/// Thrown during the sign in with email link process if a failure occurs.
/// {@endtemplate}
class LogInWithEmailLinkFailure extends AuthenticationException {
  /// {@macro log_in_with_email_link_failure}
  const LogInWithEmailLinkFailure(super.error);
}

/// {@template log_in_with_password_failure}
/// Thrown during the sign in with password process if a failure occurs.
/// {@endtemplate}
class LogInWithPasswordFailure extends AuthenticationException {
  /// {@macro log_in_with_password_failure}
  const LogInWithPasswordFailure(super.error);
}

/// {@template log_in_with_password_canceled}
/// Thrown during the sign in with password process if a cancel occurs.
/// {@endtemplate}
class LogInWithPasswordCanceled extends AuthenticationException {
  /// {@macro log_in_with_password_canceled}
  const LogInWithPasswordCanceled(super.error);
}

/// {@template log_in_with_apple_failure}
/// Thrown during the sign in with apple process if a failure occurs.
/// {@endtemplate}
class LogInWithAppleFailure extends AuthenticationException {
  /// {@macro log_in_with_apple_failure}
  const LogInWithAppleFailure(super.error);
}

/// {@template log_in_with_google_failure}
/// Thrown during the sign in with google process if a failure occurs.
/// {@endtemplate}
class LogInWithGoogleFailure extends AuthenticationException {
  /// {@macro log_in_with_google_failure}
  const LogInWithGoogleFailure(super.error);
}

/// {@template log_in_with_google_canceled}
/// Thrown during the sign in with google process if it's canceled.
/// {@endtemplate}
class LogInWithGoogleCanceled extends AuthenticationException {
  /// {@macro log_in_with_google_canceled}
  const LogInWithGoogleCanceled(super.error);
}

/// {@template log_in_with_github_failure}
/// Thrown during the sign in with Github process if a failure occurs.
/// {@endtemplate}
class LogInWithGithubFailure extends AuthenticationException {
  /// {@macro log_in_with_github_failure}
  const LogInWithGithubFailure(super.error);
}

/// {@template log_in_with_github_canceled}
/// Thrown during the sign in with Github process if it's canceled.
/// {@endtemplate}
class LogInWithGithubCanceled extends AuthenticationException {
  /// {@macro log_in_with_github_canceled}
  const LogInWithGithubCanceled(super.error);
}

/// {@template log_in_with_twitter_failure}
/// Thrown during the sign in with Twitter process if a failure occurs.
/// {@endtemplate}
class LogInWithTwitterFailure extends AuthenticationException {
  /// {@macro log_in_with_twitter_failure}
  const LogInWithTwitterFailure(super.error);
}

/// {@template log_in_with_twitter_canceled}
/// Thrown during the sign in with Twitter process if it's canceled.
/// {@endtemplate}
class LogInWithTwitterCanceled extends AuthenticationException {
  /// {@macro log_in_with_twitter_canceled}
  const LogInWithTwitterCanceled(super.error);
}

/// {@template sign_up_with_password_failure}
/// Thrown during the sign up with password process if a failure occurs.
/// {@endtemplate}
class SignUpWithPasswordFailure extends AuthenticationException {
  /// {@macro sign_up_with_password_failure}
  const SignUpWithPasswordFailure(super.error);
}

/// {@template send_password_reset_email_failure}
/// Thrown during the sending password reset email process if a failure occurs.
/// {@endtemplate}
class SendPasswordResetEmailFailure extends AuthenticationException {
  /// {@macro send_password_reset_email_failure}
  const SendPasswordResetEmailFailure(super.error);
}

/// {@template reset_password_failure}
/// This exception is thrown when there is a failure during the reset password
/// process.
/// It indicates that the reset password operation was unsuccessful.
/// {@endtemplate}
class ResetPasswordFailure extends AuthenticationException {
  /// {@macro reset_password_failure}
  const ResetPasswordFailure(super.error);
}

/// {@template log_out_failure}
/// Thrown during the logout process if a failure occurs.
/// {@endtemplate}
class LogOutFailure extends AuthenticationException {
  /// {@macro log_out_failure}
  const LogOutFailure(super.error);
}

/// A generic Authentication Client Interface.
abstract class AuthenticationClient {
  /// Stream of [AuthenticationUser] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [AuthenticationUser.anonymous] if the user is not authenticated.
  Stream<AuthenticationUser> get user;

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithPasswordFailure] if an exception occurs.
  Future<void> logInWithPassword({
    required String password,
    String? email,
    String? phone,
  });

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<void> logInWithGoogle();

  /// Starts the Sign In with Github Flow.
  ///
  /// Throws a [LogInWithGithubFailure] if an exception occurs.
  Future<void> logInWithGithub();

  /// Signs up with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithPasswordFailure] if an exception occurs.
  Future<void> signUpWithPassword({
    required String password,
    required String fullName,
    required String username,
    String? avatarUrl,
    String? email,
    String? phone,
    String? pushToken,
  });

  /// Sends a password reset email to the provided [email] address.
  ///
  /// Optionally, a [redirectTo] URL can be specified.
  ///
  /// Throws a [SendPasswordResetEmailFailure] if an exception occurs.
  Future<void> sendPasswordResetEmail({
    required String email,
    String? redirectTo,
  });

  /// Resets the password for a user using the provided [token], [email],
  /// and [newPassword].
  ///
  /// Throws a [ResetPasswordFailure] if an exception occurs.
  Future<void> resetPassword({
    required String token,
    required String email,
    required String newPassword,
  });

  /// Signs out the current user which will emit
  /// [AuthenticationUser.anonymous] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut();
}
