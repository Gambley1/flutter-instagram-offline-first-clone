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

  test('exports LogInWithGithubFailure', () {
    expect(
      () => const LogInWithGithubFailure('oops'),
      returnsNormally,
    );
  });

  test('exports LogInWithGithubCanceled', () {
    expect(
      () => const LogInWithGithubCanceled('oops'),
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
