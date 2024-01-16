// ignore_for_file: prefer_const_constructors

import 'package:database_client/database_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync_repository/powersync_repository.dart';

void main() {
  group('DatabaseClient', () {
    late PowerSyncRepository powerSyncRepository;

    setUpAll(() {
      powerSyncRepository = PowerSyncRepository();
    });
    test('can be instantiated', () {
      expect(
        DatabaseClient(powerSyncRepository),
        isNotNull,
      );
    });
  });
}
