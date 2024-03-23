/// {@template notification_exception}
/// Exceptions from the notification client.
/// {@endtemplate}
abstract class NotificationException implements Exception {
  /// {@macro notification_exception}
  const NotificationException(this.error);

  /// The error which was caught.
  final Object error;
}

/// {@template request_permission_failure}
/// Thrown during the permission requesting if a failure occurs.
/// {@endtemplate}
class RequestPermissionFailure extends NotificationException {
  /// {@macro request_permission_failure}
  const RequestPermissionFailure(super.error);
}

/// {@template fetch_token_failure}
/// Thrown during the fetching for a token if a failure occurs.
/// {@endtemplate}
class FetchTokenFailure extends NotificationException {
  /// {@macro fetch_token_failure}
  const FetchTokenFailure(super.error);
}

/// {@template notifications_client}
/// A Generic Notifications Client Interface.
/// {@endtemplate}
abstract class NotificationsClient {
  /// Broadcasts changes on `token`.
  Stream<String> onTokenRefresh();

  /// Requests the permission to send the messages.
  Future<void> requestPermission();

  /// Returns the default messaging token for this device.
  Future<String?> fetchToken({String? vapidKey});
}
