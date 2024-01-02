import 'package:authentication_client/authentication_client.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
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
    GoogleSignIn? googleSignIn,
  })  : _tokenStorage = tokenStorage,
        _powerSyncRepository = powerSyncRepository,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard() {
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

  /// Starts the Sign In with Apple Flow.
  ///
  /// Throws a [LogInWithAppleFailure] if an exception occurs.
  @override
  Future<void> logInWithApple() async {
    try {
      await _powerSyncRepository.supabase.auth.signInWithApple();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithAppleFailure(error), stackTrace);
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
        throw LogInWithGoogleCanceled(
          Exception('Sign in with Google canceled'),
        );
      }
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      if (accessToken == null) {
        throw const LogInWithGoogleCanceled('No Access Token found.');
      }
      if (idToken == null) {
        throw const LogInWithGoogleCanceled('No ID Token found.');
      }

      await _powerSyncRepository.supabase.auth.signInWithIdToken(
        provider: Provider.google,
        accessToken: accessToken,
        idToken: idToken,
      );
    } on LogInWithGoogleCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithGoogleFailure(error), stackTrace);
    }
  }

  /// Starts the Sign In with Facebook Flow.
  ///
  /// Throws a [LogInWithFacebookCanceled] if the flow is canceled by the user.
  /// Throws a [LogInWithFacebookFailure] if an exception occurs.
  @override
  Future<void> logInWithFacebook() async {
    try {} on LogInWithFacebookCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithFacebookFailure(error), stackTrace);
    }
  }

  /// Starts the Sign In with Twitter Flow.
  ///
  /// Throws a [LogInWithTwitterCanceled] if the flow is canceled by the user.
  /// Throws a [LogInWithTwitterFailure] if an exception occurs.
  @override
  Future<void> logInWithTwitter() async {
    try {} on LogInWithTwitterCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithTwitterFailure(error), stackTrace);
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

  /// Sends an authentication link to the provided [email].
  ///
  /// Opening the link redirects to the app with [appPackageName]
  /// using Firebase Dynamic Links and authenticates the user
  /// based on the provided email link.
  ///
  /// Throws a [SendLoginEmailLinkFailure] if an exception occurs.
  @override
  Future<void> sendLoginEmailLink({
    required String email,
    required String appPackageName,
  }) async {
    try {
      // final redirectUrl = Uri.https(
      //   const String.fromEnvironment('FLAVOR_DEEP_LINK_DOMAIN'),
      //   const String.fromEnvironment('FLAVOR_DEEP_LINK_PATH'),
      //   <String, String>{'email': email},
      // );

      // final actionCodeSettings = firebase_auth.ActionCodeSettings(
      //   url: redirectUrl.toString(),
      //   handleCodeInApp: true,
      //   iOSBundleId: appPackageName,
      //   androidPackageName: appPackageName,
      //   androidInstallApp: true,
      // );

      // await _firebaseAuth.sendSignInLinkToEmail(
      //   email: email,
      //   actionCodeSettings: actionCodeSettings,
      // );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SendLoginEmailLinkFailure(error), stackTrace);
    }
  }

  /// Checks if an incoming [emailLink] is a sign-in with email link.
  ///
  /// Throws a [IsLogInWithEmailLinkFailure] if an exception occurs.
  @override
  bool isLogInWithEmailLink({required String emailLink}) {
    try {
      // return _firebaseAuth.isSignInWithEmailLink(emailLink);
      return false;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(IsLogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  /// Signs in with the provided [emailLink].
  ///
  /// Throws a [LogInWithEmailLinkFailure] if an exception occurs.
  @override
  Future<void> logInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      await _powerSyncRepository.supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb
            ? null
            : 'io._powerSyncRepository.supabase.flutterquickstart://login-callback/',
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
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
      isNewUser: createdAt == lastSignInAt,
    );
  }
}
