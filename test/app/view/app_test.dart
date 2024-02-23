import 'package:flutter/material.dart';
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
    test('test `separated by` extension', () {
      const mockWidgets = [
        Text('Hello', key: ValueKey('helloTextKey')),
        Text('World', key: ValueKey('worldTextKey')),
      ];

      const separator = SizedBox(height: 12, key: ValueKey('separatorKey'));

      void separatedBy<T>(Iterable<T> items, T separator) {
        final stopwatch = Stopwatch()..start();
        items.separatedBy(separator);
        stopwatch.stop();
        logD('Separated by elapsed time: ${stopwatch.elapsed.inMicroseconds}');
      }

      void insertBetween<T>(List<T> items, T separator) {
        final stopwatch = Stopwatch()..start();
        items.insertBetween(separator);
        stopwatch.stop();
        logD(
          'Insert between elapsed time: ${stopwatch.elapsed.inMicroseconds}',
        );
      }

      separatedBy(mockWidgets, separator);
      insertBetween(mockWidgets, separator);
    });
  });
}
