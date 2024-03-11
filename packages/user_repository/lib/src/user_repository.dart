import 'package:authentication_client/authentication_client.dart';
import 'package:database_client/database_client.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/user_repository.dart';

/// {@template user_repository}
/// A package that manages user flow.
/// {@endtemplate}
class UserRepository implements UserBaseRepository {
  /// {@macro user_repository}
  const UserRepository({
    required Client client,
    required AuthenticationClient authenticationClient,
  })  : _client = client,
        _authenticationClient = authenticationClient;

  final Client _client;
  final AuthenticationClient _authenticationClient;

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  Stream<User> get user => _authenticationClient.user
      .map((user) => User.fromAuthenticationUser(authenticationUser: user))
      .startWith(User.anonymous)
      .asBroadcastStream();

  /// Streams an [AuthState] and emits new [AuthState] whenever auth state
  /// changed.
  Stream<AuthState> authStateChanges() =>
      Supabase.instance.client.auth.onAuthStateChange.asBroadcastStream();

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

  /// Starts the Sign In with Facebook Flow.
  ///
  /// Throws a [LogInWithFacebookCanceled] if the flow is canceled by the user.
  /// Throws a [LogInWithFacebookFailure] if an exception occurs.
  Future<void> logInWithFacebook() async {
    try {
      await _authenticationClient.logInWithFacebook();
    } on LogInWithFacebookFailure {
      rethrow;
    } on LogInWithFacebookCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithFacebookFailure(error), stackTrace);
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

  @override
  String? get currentUserId => _client.currentUserId;

  @override
  Stream<User> profile({required String id}) => _client.profile(id: id);

  @override
  Future<bool> isUserExists({required String id}) =>
      _client.isUserExists(id: id);

  @override
  Stream<int> followersCountOf({required String userId}) =>
      _client.followersCountOf(userId: userId);

  @override
  Stream<int> followingsCountOf({required String userId}) =>
      _client.followingsCountOf(userId: userId);

  @override
  Future<List<User>> getFollowers({required String userId}) =>
      _client.getFollowers(userId: userId);

  @override
  Future<List<User>> getFollowings({required String userId}) =>
      _client.getFollowings(userId: userId);

  @override
  Future<void> follow({
    required String followToId,
    String? followerId,
  }) =>
      _client.follow(
        followToId: followToId,
        followerId: followerId,
      );

  @override
  Future<void> removeFollower({required String id}) =>
      _client.removeFollower(id: id);

  @override
  Future<void> unfollow({required String unfollowId, String? unfollowerId}) =>
      _client.unfollow(unfollowId: unfollowId, unfollowerId: unfollowerId);

  @override
  Future<bool> isFollowed({
    required String followerId,
    required String userId,
  }) =>
      _client.isFollowed(followerId: followerId, userId: userId);

  @override
  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  }) =>
      _client.followingStatus(followerId: followerId, userId: userId);

  @override
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
  }) =>
      _client.updateUser(
        fullName: fullName,
        email: email,
        username: username,
        avatarUrl: avatarUrl,
        pushToken: pushToken,
      );

  @override
  Future<List<User>> searchUsers({
    required String userId,
    required int limit,
    required int offset,
    required String? query,
    String? excludeUserIds,
  }) =>
      _client.searchUsers(
        userId: userId,
        limit: limit,
        offset: offset,
        query: query,
        excludeUserIds: excludeUserIds,
      );

  @override
  Stream<List<User>> streamFollowers({required String userId}) =>
      _client.streamFollowers(userId: userId);

  @override
  Stream<List<User>> streamFollowings({required String userId}) =>
      _client.streamFollowings(userId: userId);
}
