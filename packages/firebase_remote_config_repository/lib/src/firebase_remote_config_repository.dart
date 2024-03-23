import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';

/// {@template firebase_remote_config_exception}
/// Exceptions from the Firebase remote config repository.
/// {@endtemplate}
abstract class FirebaseRemoteConfigException implements Exception {
  /// {@macro firebase_remote_config_exception}
  const FirebaseRemoteConfigException(this.error);

  /// The error which was caught.
  final Object error;
}

/// {@template initialize_firebase_remote_config_failure}
/// Thrown during the initialization of the Firebase remote
/// if a failure occurs.
/// {@endtemplate}
class InitializeFirebaseRemoteConfigFailure
    extends FirebaseRemoteConfigException {
  /// {@macro initialize_firebase_remote_config_failure}
  const InitializeFirebaseRemoteConfigFailure(super.error);
}

/// {@template check_feature_available_failure}
/// Thrown during the check whether the feature is available
/// if a failure occurs.
/// {@endtemplate}
class CheckFeatureAvailableFailure extends FirebaseRemoteConfigException {
  /// {@macro check_feature_available_failure}
  const CheckFeatureAvailableFailure(super.error);
}

/// {@template fetch_remote_data_failure}
/// Thrown during the remote data fetch if a failure occurs.
/// {@endtemplate}
class FetchRemoteDataFailure extends FirebaseRemoteConfigException {
  /// {@macro fetch_remote_data_failure}
  const FetchRemoteDataFailure(super.error);
}

/// {@template activate_failure}
/// Thrown during the activate if a failure occurs.
/// {@endtemplate}
class ActivateFailure extends FirebaseRemoteConfigException {
  /// {@macro activate_failure}
  const ActivateFailure(super.error);
}

/// {@template fetch_and_activate_failure}
/// Thrown during the fetch and activate if a failure occurs.
/// {@endtemplate}
class FetchAndActivateFailure extends FirebaseRemoteConfigException {
  /// {@macro fetch_and_activate_failure}
  const FetchAndActivateFailure(super.error);
}

/// {@template set_config_failure}
/// Thrown during the config set if a failure occurs.
/// {@endtemplate}
class SetConfigFailure extends FirebaseRemoteConfigException {
  /// {@macro set_config_failure}
  const SetConfigFailure(super.error);
}

/// {@template firebase_remote_config_repository}
/// A package that communicates with the Firebase remote config.
/// {@endtemplate}
class FirebaseRemoteConfigRepository {
  /// {@macro firebase_remote_config_repository}
  FirebaseRemoteConfigRepository({
    required FirebaseRemoteConfig firebaseRemoteConfig,
  }) : _firebaseRemoteConfig = firebaseRemoteConfig {
    unawaited(_initializeRemoteConfig());
  }

  final FirebaseRemoteConfig _firebaseRemoteConfig;

  /// Initializes the [FirebaseRemoteConfig].
  Future<void> _initializeRemoteConfig() async {
    try {
      await _firebaseRemoteConfig.ensureInitialized();
      await setConfigSetting(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await fetchAndActivate();
    } on SetConfigFailure {
      rethrow;
    } on FetchAndActivateFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        InitializeFirebaseRemoteConfigFailure(error),
        stackTrace,
      );
    }
  }

  /// Checks from the [FirebaseRemoteConfig] whether the feature by [key] is
  /// available to use in the application.
  bool isFeatureAvailable(String key) {
    try {
      return _firebaseRemoteConfig.getBool(key);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        CheckFeatureAvailableFailure(error),
        stackTrace,
      );
    }
  }

  /// Fetches the static remote data from the [FirebaseRemoteConfig].
  String fetchRemoteData(String key) {
    try {
      return _firebaseRemoteConfig.getString(key);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Activates the [FirebaseRemoteConfig] so that we can fetch for new
  /// changes.
  Future<bool> activate() {
    try {
      return _firebaseRemoteConfig.activate();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(ActivateFailure(error), stackTrace);
    }
  }

  /// Broadcasts the stream of [RemoteConfigUpdate] whenever there is a change
  /// in [FirebaseRemoteConfig], e.g when some features become avaiable to use.
  Stream<RemoteConfigUpdate> onConfigUpdated() =>
      _firebaseRemoteConfig.onConfigUpdated.asBroadcastStream();

  /// Sets up custom [FirebaseRemoteConfig] settings.
  Future<void> setConfigSetting(
    RemoteConfigSettings remoteConfigSettings,
  ) async {
    try {
      await _firebaseRemoteConfig.setConfigSettings(remoteConfigSettings);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SetConfigFailure(error), stackTrace);
    }
  }

  /// Performs a fetch and activate operation, as a convenience.
  Future<bool> fetchAndActivate() async {
    try {
      return _firebaseRemoteConfig.fetchAndActivate();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(FetchAndActivateFailure(error), stackTrace);
    }
  }
}
