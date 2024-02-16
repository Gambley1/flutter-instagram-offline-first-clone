// ignore_for_file: prefer_const_constructors

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync_repository/powersync_repository.dart';

void main() {
  group('PowerSyncRepository', () {
    late PowerSyncRepository powerSyncRepository;
    const isDev = true;

    setUpAll(() {
      WidgetsFlutterBinding.ensureInitialized();

      powerSyncRepository = PowerSyncRepository(isDev: isDev);
    });
    test('Is dev false', () {
      expect(powerSyncRepository.isDev, equals(isDev));
    });
  });
}
