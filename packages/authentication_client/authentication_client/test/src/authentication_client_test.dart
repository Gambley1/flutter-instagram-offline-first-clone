import 'package:authentication_client/authentication_client.dart';
import 'package:flutter_test/flutter_test.dart';

// AuthenticationClient is exported and can be implemented
class FakeAuthenticationClient extends Fake implements AuthenticationClient {}

void main() {
  test('AuthenticationClient can be implemented', () {
    expect(FakeAuthenticationClient.new, returnsNormally);
  });

  test('exports LogInWithGoogleFailure', () {
    expect(
      () => const LogInWithGoogleFailure('oops'),
      returnsNormally,
    );
  });

  test('exports LogInWithGoogleCanceled', () {
    expect(
      () => const LogInWithGoogleCanceled('oops'),
      returnsNormally,
    );
  });

  test('exports LogInWithFacebookFailure', () {
    expect(
      () => const LogInWithFacebookFailure('oops'),
      returnsNormally,
    );
  });

  test('exports LogInWithFacebookCanceled', () {
    expect(
      () => const LogInWithFacebookCanceled('oops'),
      returnsNormally,
    );
  });

  test('exports LogOutFailure', () {
    expect(
      () => const LogOutFailure('oops'),
      returnsNormally,
    );
  });
}
