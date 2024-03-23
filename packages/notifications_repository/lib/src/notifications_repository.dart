import 'package:notifications_client/notifications_client.dart';

/// {@template notifications_repository}
/// A repository that manages notification permissions and token fetching.
/// {@endtemplate}
class NotificationsRepository {
  /// {@macro notifications_repository}
  const NotificationsRepository({
    required NotificationsClient notificationsClient,
  }) : _notificationsClient = notificationsClient;

  final NotificationsClient _notificationsClient;

  /// Returns a stream that emits a new token whenever the token is refreshed.
  Stream<String> onTokenRefresh() => _notificationsClient.onTokenRefresh();

  /// Requests permission to send notifications.
  /// If permission is granted, the method resolves successfully.
  /// If permission is denied, an error is thrown.
  Future<void> requestPermission() async {
    try {
      await _notificationsClient.requestPermission();
    } on RequestPermissionFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(RequestPermissionFailure(error), stackTrace);
    }
  }

  /// Fetches the current notification token.
  /// If fetching the token fails, an error is thrown.
  Future<String?> fetchToken() async {
    try {
      return _notificationsClient.fetchToken();
    } on FetchTokenFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(FetchTokenFailure(error), stackTrace);
    }
  }
}
