import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

/// {@template firebase_notifications_client}
/// A Firebase Cloud Messaging notifications client.
/// {@endtemplate}
class FirebaseNotificationsClient {
  /// {@macro firebase_notifications_client}
  const FirebaseNotificationsClient({
    required FirebaseMessaging firebaseMessaging,
  }) : _firebaseMessaging = firebaseMessaging;

  final FirebaseMessaging _firebaseMessaging;

  /// Broadcasts changes on [FirebaseMessaging] token.
  Stream<String> onTokenRefresh() => _firebaseMessaging.onTokenRefresh;

  /// Requests the permission to send the Firebase Cloud Notifications.
  Future<void> requestPermission() => _firebaseMessaging.requestPermission();

  /// Returns the default Firebase Cloud Messaging token for this device.
  Future<String?> getToken({String? vapidKey}) =>
      _firebaseMessaging.getToken(vapidKey: vapidKey);
}
