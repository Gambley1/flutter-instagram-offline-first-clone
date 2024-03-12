import 'package:authentication_client/authentication_client.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:token_storage/token_storage.dart';

/// {@template firebase_authentication_client}
/// A Supabase implementation of the [AuthenticationClient] interface.
/// {@endtemplate}
class SupabaseAuthenticationClient implements AuthenticationClient {
  /// {@macro firebase_authentication_client}
  SupabaseAuthenticationClient({
    required PowerSyncRepository powerSyncRepository,
    required TokenStorage tokenStorage,
    required GoogleSignIn googleSignIn,
  })  : _tokenStorage = tokenStorage,
        _powerSyncRepository = powerSyncRepository,
        _googleSignIn = googleSignIn {
    user.listen(_onUserChanged);
  }

  final TokenStorage _tokenStorage;
  final PowerSyncRepository _powerSyncRepository;
  final GoogleSignIn _googleSignIn;

  /// Stream of [AuthenticationUser] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [AuthenticationUser.anonymous] if the user is not authenticated.
  @override
  Stream<AuthenticationUser> get user {
    return _powerSyncRepository.authStateChanges().map((state) {
      final supabaseUser = state.session?.user;
      return supabaseUser == null
          ? AuthenticationUser.anonymous
          : supabaseUser.toUser;
    });
  }

  @override
  Future<void> logInWithPassword({
    required String password,
    String? email,
    String? phone,
  }) async {
    try {
      if (email == null && phone == null) {
        throw const LogInWithPasswordCanceled(
          'You must provide either an email, phone number.',
        );
      }
      await _powerSyncRepository.supabase.auth
          .signInWithPassword(email: email, phone: phone, password: password);
    } on LogInWithPasswordCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithPasswordFailure(error), stackTrace);
    }
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleCanceled] if the flow is canceled by the user.
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  @override
  Future<void> logInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const LogInWithGoogleCanceled(
          'Sign in with Google canceled. No user found!',
        );
      }
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      if (accessToken == null) {
        throw const LogInWithGoogleFailure('No Access Token found.');
      }
      if (idToken == null) {
        throw const LogInWithGoogleFailure('No ID Token found.');
      }

      await _powerSyncRepository.supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } on LogInWithGoogleCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithGoogleFailure(error), stackTrace);
    }
  }

  /// Starts the Sign In with Github Flow.
  ///
  /// Throws a [LogInWithGithubCanceled] if the flow is canceled by the user.
  /// Throws a [LogInWithGithubFailure] if an exception occurs.
  @override
  Future<void> logInWithGithub() async {
    try {
      await _powerSyncRepository.supabase.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo:
            kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );
    } on LogInWithGithubCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithGithubFailure(error), stackTrace);
    }
  }

  @override
  Future<void> signUpWithPassword({
    required String password,
    required String fullName,
    required String username,
    String? avatarUrl,
    String? email,
    String? phone,
    String? pushToken,
  }) async {
    final data = {
      'full_name': fullName,
      'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (pushToken != null) 'push_token': pushToken,
    };
    try {
      await _powerSyncRepository.supabase.auth.signUp(
        email: email,
        phone: phone,
        password: password,
        data: data,
        emailRedirectTo: kIsWeb
            ? null
            : 'io._powerSyncRepository.supabase.flutterquickstart://login-callback/',
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SignUpWithPasswordFailure(error), stackTrace);
    }
  }

  /// Signs out the current user which will emit
  /// [AuthenticationUser.anonymous] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  @override
  Future<void> logOut() async {
    try {
      await Future.wait([
        _powerSyncRepository.supabase.auth.signOut(),
        _powerSyncRepository.db().disconnectAndClear(),
        _googleSignIn.signOut(),
      ]);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogOutFailure(error), stackTrace);
    }
  }

  /// Updates the user token in [TokenStorage] if the user is authenticated.
  Future<void> _onUserChanged(AuthenticationUser user) async {
    if (!user.isAnonymous) {
      await _tokenStorage.saveToken(user.id);
    } else {
      await _tokenStorage.clearToken();
    }
  }
}

extension on supabase.User {
  AuthenticationUser get toUser {
    return AuthenticationUser(
      id: id,
      email: email,
      fullName: userMetadata?['full_name'] as String?,
      username: userMetadata?['username'] as String?,
      avatarUrl: userMetadata?['avatar_url'] as String?,
      pushToken: userMetadata?['push_token'] as String?,
      isNewUser: createdAt == lastSignInAt,
    );
  }
}
