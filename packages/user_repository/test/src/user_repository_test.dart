import 'package:authentication_client/authentication_client.dart';
import 'package:database_client/database_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:user_repository/user_repository.dart';

class MockAuthenticationClient extends Mock implements AuthenticationClient {}

class MockDatabaseClient extends Mock implements DatabaseClient {}

class MockPowerSyncRepository extends Mock implements PowerSyncRepository {}

void main() {
  group('UserRepository', () {
    late DatabaseClient databaseClient;
    late AuthenticationClient authenticationClient;

    setUp(() {
      databaseClient = MockDatabaseClient();
      authenticationClient = MockAuthenticationClient();
    });
    test('can be instantiated', () {
      expect(
        UserRepository(
          databaseClient: databaseClient,
          authenticationClient: authenticationClient,
        ),
        returnsNormally,
      );
    });
  });
}
