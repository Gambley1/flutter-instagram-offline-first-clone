import 'dart:async';
import 'dart:developer';

import 'package:firebase_config/firebase_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/firebase_options_prod.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/slang/translations.g.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

typedef AppBuilder = FutureOr<Widget> Function(
  PowerSyncRepository,
  FirebaseMessaging,
  SharedPreferences,
  FirebaseConfig,
);

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError ${bloc.runtimeType}', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  logD('Handling a background message: ${message.toMap()}');
}

Future<void> bootstrap(
  AppBuilder builder, {
  required bool isDev,
}) async {
  FlutterError.onError = (details) {
    logE(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      LocaleSettings.useDeviceLocale();
      LocaleSettings.setLocale(AppLocale.en);

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getTemporaryDirectory(),
      );

      final powerSyncRepository = PowerSyncRepository(isDev: isDev);
      await powerSyncRepository.initialize();

      final firebaseMessaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      final sharedPreferences = await SharedPreferences.getInstance();

      final firebaseRemoteConfig = FirebaseRemoteConfig.instance;
      final remoteConfig =
          FirebaseConfig(firebaseRemoteConfig: firebaseRemoteConfig);

      await remoteConfig.init();

      runApp(
        TranslationProvider(
          child: await builder(
            powerSyncRepository,
            firebaseMessaging,
            sharedPreferences,
            remoteConfig,
          ),
        ),
      );
    },
    (error, stack) {
      logE(error.toString(), stackTrace: stack);
    },
  );
}
