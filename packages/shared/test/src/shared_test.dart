// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('Shared', () {
    group('Models', () {
      test('Schema not null', () {
        expect(schema, isNotNull);
      });
    });
  });
}
