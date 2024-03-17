// ignore_for_file: prefer_const_constructors

import 'package:database_client/database_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseClient extends Mock implements DatabaseClient {}

void main() {
  group('DatabaseClient', () {
    late DatabaseClient databaseClient;

    setUpAll(() {
      databaseClient = MockDatabaseClient();
    });
    test('can be instantiated', () {
      expect(databaseClient, returnsNormally);
    });
  });
}
