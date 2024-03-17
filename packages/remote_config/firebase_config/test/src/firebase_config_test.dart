import 'package:firebase_config/firebase_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseConfig extends Mock implements FirebaseConfig {}

void main() {
  group('FirebaseConfig', () {
    late FirebaseConfig firebaseConfig;

    setUp(() => firebaseConfig = MockFirebaseConfig());
    test('can be instantiated', () {
      expect(firebaseConfig, returnsNormally);
    });
  });
}
