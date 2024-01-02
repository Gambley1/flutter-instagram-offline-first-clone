import 'package:authentication_client/authentication_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthenticationUser', () {
    test('supports value equality', () {
      const userA = AuthenticationUser(id: 'A');
      const secondUserA = AuthenticationUser(id: 'A');
      const userB = AuthenticationUser(id: 'B');

      expect(userA, equals(secondUserA));
      expect(userA, isNot(equals(userB)));
    });

    test('isAnonymous returns true for anonymous user', () {
      expect(AuthenticationUser.anonymous.isAnonymous, isTrue);
    });
  });
}
