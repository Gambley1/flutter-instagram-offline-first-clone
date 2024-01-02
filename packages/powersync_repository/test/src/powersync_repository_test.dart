// ignore_for_file: prefer_const_constructors

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync_repository/powersync_repository.dart';

void main() {
  group('PowersyncRepository', () {
    late PowerSyncRepository powerSyncRepository;
    const isDev = false;

    setUpAll(() {
      WidgetsFlutterBinding.ensureInitialized();

      powerSyncRepository = PowerSyncRepository(isDev: isDev);
    });
    test('Is dev false', () {
      expect(powerSyncRepository.isDev, equals(isDev));
    });
    test('Can check current mode(offline or online)', () {
      expect(powerSyncRepository.isOfflineMode(), anyOf([false, true]));
    });
  });
}
