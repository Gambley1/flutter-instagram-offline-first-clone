// ignore_for_file: prefer_const_constructors

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

class MockPowerSyncRepository extends Mock implements PowerSyncRepository {
  MockPowerSyncRepository({required this.envValue});

  final EnvValue envValue;

  @override
  EnvValue get env => envValue;
}

class MockAppFlavor extends Mock implements AppFlavor {}

void main() {
  group('PowerSyncRepository', () {
    late AppFlavor appFlavor;
    late PowerSyncRepository powerSyncRepository;

    setUpAll(() {
      WidgetsFlutterBinding.ensureInitialized();

      appFlavor = MockAppFlavor();
      powerSyncRepository = MockPowerSyncRepository(envValue: appFlavor.getEnv);
    });
    test('can be instantiated', () {
      expect(powerSyncRepository, returnsNormally);
    });
  });
}
