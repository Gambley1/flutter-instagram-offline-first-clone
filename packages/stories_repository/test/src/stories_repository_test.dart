// ignore_for_file: prefer_const_constructors
import 'package:mocktail/mocktail.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:test/test.dart';

class StoriesMockRepository extends Mock implements StoriesRepository {}

void main() {
  group('StoriesRepository', () {
    late StoriesRepository storiesRepository;

    setUp(() => storiesRepository = StoriesMockRepository());
    test('can be instantiated', () {
      expect(storiesRepository, isNotNull);
    });
  });
}
