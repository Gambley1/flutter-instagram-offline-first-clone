import 'package:firebase_config/firebase_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FirebaseConfigMock extends Mock implements FirebaseConfig {}

void main() {
  group('FirebaseConfig', () {
    late FirebaseConfig firebaseConfig;

    setUp(() => firebaseConfig = FirebaseConfigMock());
    test('can be instantiated', () {
      expect(firebaseConfig, isNotNull);
    });
  });
}
