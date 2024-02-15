import 'package:database_client/database_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:search_repository/search_repository.dart';
import 'package:test/test.dart';

class MockDatabaseClient extends Mock implements DatabaseClient {}

void main() {
  group('SearchRepository', () {
    test('can be instantiated', () {
      expect(
        SearchRepository(client: MockDatabaseClient()),
        isNotNull,
      );
    });
  });
}
