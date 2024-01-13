import 'dart:developer' as developer;

import 'package:firebase_remote_config/firebase_remote_config.dart';

/// {@template firebase_config}
/// A library that communicates with the Firebase remote config.
/// {@endtemplate}
class FirebaseConfig {
  /// {@macro firebase_config}
  const FirebaseConfig({required FirebaseRemoteConfig firebaseRemoteConfig})
      : _firebaseRemoteConfig = firebaseRemoteConfig;

  final FirebaseRemoteConfig _firebaseRemoteConfig;

  /// Initializes the [FirebaseRemoteConfig].
  Future<void> init() async {
    try {
      await _firebaseRemoteConfig.ensureInitialized();
      await setConfigSetting(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await fetchAndActivate();
    } catch (error, stackTrace) {
      developer.log(
        'Unable to initialize Firebase Remote Config',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Checks from the [FirebaseRemoteConfig] whether the feature by [key] is
  /// available to use in the application.
  bool isFeatureAvailabe(String key) => _firebaseRemoteConfig.getBool(key);

  /// Fetches the static remote data from the [FirebaseRemoteConfig].
  String getRemoteData(String key) => _firebaseRemoteConfig.getString(key);

  /// Activates the [FirebaseRemoteConfig] so that we can fetch for new
  /// changes.
  Future<bool> activate() => _firebaseRemoteConfig.activate();

  /// Broadcasts the stream of [RemoteConfigUpdate] whenever there is a change
  /// in [FirebaseRemoteConfig], e.g when some features become avaiable to use.
  Stream<RemoteConfigUpdate> onConfigUpdated() =>
      _firebaseRemoteConfig.onConfigUpdated.asBroadcastStream();

  /// Sets up custom [FirebaseRemoteConfig] settings.
  Future<void> setConfigSetting(RemoteConfigSettings remoteConfigSettings) =>
      _firebaseRemoteConfig.setConfigSettings(remoteConfigSettings);

  /// Performs a fetch and activate operation, as a convenience.
  Future<bool> fetchAndActivate() => _firebaseRemoteConfig.fetchAndActivate();
}
