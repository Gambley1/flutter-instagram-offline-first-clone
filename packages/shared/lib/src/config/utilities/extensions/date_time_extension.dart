import 'package:jiffy/jiffy.dart';

/// Extensions on [Jiffy].
extension JiffyX on Jiffy {
  /// Returns the current date time in [String] format.
  static String now() => Jiffy.now().dateTime.toIso8601String();
}
