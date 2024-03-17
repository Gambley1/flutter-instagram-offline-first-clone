import 'package:mocktail/mocktail.dart';
import 'package:search_repository/search_repository.dart';
import 'package:test/test.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  group('SearchRepository', () {
    late SearchRepository searchRepository;

    setUp(() => searchRepository = MockSearchRepository());
    test('can be instantiated', () {
      expect(searchRepository, returnsNormally);
    });
  });
}
