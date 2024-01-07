import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      // await tester.pumpWidget(const App());
    });
    test('test 2 list merging', () {
      final list1 = [
        Story(
          id: '123',
          contentUrl: 'abc',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 1)),
        ),
        Story(
          id: '456',
          contentUrl: 'def',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 1)),
        ),
      ];

      final list2 = [
        Story(
          id: '123',
          contentUrl: 'abc',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 1)),
          seen: true,
        ),
      ];

      final merged = list1.map(
        (story) => list2.map((e) => e.id).contains(story.id)
            ? story.copyWith(seen: true)
            : story,
      );

      logI(merged);

      expect(merged.length, equals(2));
    });
  });
}
