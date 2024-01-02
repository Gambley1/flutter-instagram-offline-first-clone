import 'package:jiffy/jiffy.dart';

extension JiffyX on Jiffy {
  static String now() => Jiffy.now().dateTime.toIso8601String();
}
