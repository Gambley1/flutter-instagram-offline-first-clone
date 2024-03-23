import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications_client/notifications_client.dart';

/// {@template firebase_notifications_client}
/// A Firebase Cloud Messaging notifications client.
/// {@endtemplate}
class FirebaseNotificationsClient implements NotificationsClient {
  /// {@macro firebase_notifications_client}
  const FirebaseNotificationsClient({
    required FirebaseMessaging firebaseMessaging,
  }) : _firebaseMessaging = firebaseMessaging;

  final FirebaseMessaging _firebaseMessaging;

  /// Broadcasts changes on [FirebaseMessaging] token.
  @override
  Stream<String> onTokenRefresh() => _firebaseMessaging.onTokenRefresh;

  /// Requests the permission to send the Firebase Cloud Notifications.
  @override
  Future<void> requestPermission() => _firebaseMessaging.requestPermission();

  /// Returns the default Firebase Cloud Messaging token for this device.
  @override
  Future<String?> fetchToken({String? vapidKey}) =>
      _firebaseMessaging.getToken(vapidKey: vapidKey);
}
