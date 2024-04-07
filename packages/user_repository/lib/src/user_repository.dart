import 'package:authentication_client/authentication_client.dart';
import 'package:database_client/database_client.dart';
import 'package:user_repository/user_repository.dart';

/// {@template user_repository}
/// A package that manages user flow.
/// {@endtemplate}
class UserRepository implements UserBaseRepository {
  /// {@macro user_repository}
  const UserRepository({
    required DatabaseClient databaseClient,
    required AuthenticationClient authenticationClient,
  })  : _databaseClient = databaseClient,
        _authenticationClient = authenticationClient;

  final DatabaseClient _databaseClient;
  final AuthenticationClient _authenticationClient;

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  Stream<User> get user => _authenticationClient.user
      .map((user) => User.fromAuthenticationUser(authenticationUser: user))
      .asBroadcastStream();

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleCanceled] if the flow is canceled by the user.
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<void> logInWithGoogle() async {
    try {
      await _authenticationClient.logInWithGoogle();
    } on LogInWithGoogleFailure {
      rethrow;
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
  Future<void> logInWithGithub() async {
    try {
      await _authenticationClient.logInWithGithub();
    } on LogInWithGithubFailure {
      rethrow;
    } on LogInWithGithubCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithGithubFailure(error), stackTrace);
    }
  }

  /// Signs out the current user which will emit
  /// [User.anonymous] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await _authenticationClient.logOut();
    } on LogOutFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogOutFailure(error), stackTrace);
    }
  }

  /// Logins in with the provided [password].
  Future<void> logInWithPassword({
    required String password,
    String? email,
    String? phone,
  }) async {
    try {
      await _authenticationClient.logInWithPassword(
        email: email,
        phone: phone,
        password: password,
      );
    } on LogInWithPasswordFailure {
      rethrow;
    } on LogInWithPasswordCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithPasswordFailure(error), stackTrace);
    }
  }

  /// Sign up with the provided [password].
  Future<void> signUpWithPassword({
    required String password,
    required String fullName,
    required String username,
    String? avatarUrl,
    String? email,
    String? phone,
    String? pushToken,
  }) async {
    try {
      await _authenticationClient.signUpWithPassword(
        email: email,
        phone: phone,
        password: password,
        fullName: fullName,
        username: username,
        avatarUrl: avatarUrl,
        pushToken: pushToken,
      );
    } on SignUpWithPasswordFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SignUpWithPasswordFailure(error), stackTrace);
    }
  }

  /// Sends a password reset email to the provided [email].
  /// Optionally allows specifying a [redirectTo] url to redirect
  /// the user to after resetting their password.
  Future<void> sendPasswordResetEmail({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await _authenticationClient.sendPasswordResetEmail(
        email: email,
        redirectTo: redirectTo,
      );
    } on SendPasswordResetEmailFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SendPasswordResetEmailFailure(error),
        stackTrace,
      );
    }
  }

  /// Resets the password for the user with the given [email]
  /// using the provided [token]. Updates the password to
  /// the new [newPassword].
  Future<void> resetPassword({
    required String token,
    required String email,
    required String newPassword,
  }) async {
    try {
      await _authenticationClient.resetPassword(
        token: token,
        email: email,
        newPassword: newPassword,
      );
    } on ResetPasswordFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(ResetPasswordFailure, stackTrace);
    }
  }

  @override
  String? get currentUserId => _databaseClient.currentUserId;

  @override
  Stream<User> profile({required String id}) => _databaseClient.profile(id: id);

  @override
  Stream<int> followersCountOf({required String userId}) =>
      _databaseClient.followersCountOf(userId: userId);

  @override
  Stream<int> followingsCountOf({required String userId}) =>
      _databaseClient.followingsCountOf(userId: userId);

  @override
  Future<List<User>> getFollowers({String? userId}) =>
      _databaseClient.getFollowers(userId: userId);

  @override
  Future<List<User>> getFollowings({String? userId}) =>
      _databaseClient.getFollowings(userId: userId);

  @override
  Future<void> follow({
    required String followToId,
    String? followerId,
  }) =>
      _databaseClient.follow(
        followToId: followToId,
        followerId: followerId,
      );

  @override
  Future<void> removeFollower({required String id}) =>
      _databaseClient.removeFollower(id: id);

  @override
  Future<void> unfollow({required String unfollowId, String? unfollowerId}) =>
      _databaseClient.unfollow(
        unfollowId: unfollowId,
        unfollowerId: unfollowerId,
      );

  @override
  Future<bool> isFollowed({
    required String userId,
    String? followerId,
  }) =>
      _databaseClient.isFollowed(followerId: followerId, userId: userId);

  @override
  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  }) =>
      _databaseClient.followingStatus(followerId: followerId, userId: userId);

  @override
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
  }) =>
      _databaseClient.updateUser(
        fullName: fullName,
        email: email,
        username: username,
        avatarUrl: avatarUrl,
        pushToken: pushToken,
      );

  @override
  Future<List<User>> searchUsers({
    required int limit,
    required int offset,
    required String? query,
    String? userId,
    String? excludeUserIds,
  }) =>
      _databaseClient.searchUsers(
        userId: userId,
        limit: limit,
        offset: offset,
        query: query,
        excludeUserIds: excludeUserIds,
      );

  @override
  Stream<List<User>> followers({required String userId}) =>
      _databaseClient.followers(userId: userId);
}
