@Tags(['presubmit-only'])
library;

import 'package:build_verify/build_verify.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'ensure_build',
    () {
      expectBuildClean(
        customCommand: [
          'flutter',
          'pub',
          'run',
          'build_runner',
          'build',
          '--delete-conflicting-outputs',
        ],
      );
    },
    tags: ['presubmit-only'],
  );
}
