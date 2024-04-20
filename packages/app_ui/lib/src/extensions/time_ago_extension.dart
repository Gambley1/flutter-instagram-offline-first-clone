import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// {@template time_ago_extension}
/// A mixin that provides a custom implementation of the `lessThanOneMinute`
/// function for the `LookupMessages` class.
///
/// This mixin adds a `_lessThanOneMinute` function that takes the number of
/// second sand returns a formatted string with the number of seconds and the
/// specified text.
///
/// Usage:
/// ```dart
/// class MyMessages extends LookupMessages with TimeAgoLessThanOneMinuteMixin {
///   String get secondsText => 'sec.';
/// }
/// ```
/// {@endtemplate}
mixin TimeAgoLessThanOneMinuteMixin on timeago.LookupMessages {
  /// The text display in `lessThanOneMinute` function.
  String secondsText(int seconds);

  String _lessThanOneMinute(int seconds) => '${seconds == 0 ? '1' : seconds} '
      '${secondsText(seconds)}';
}

/// {@template en_custom_short_messages}
/// A custom implementation of the `LookupMessages` class for the English
/// language.
/// This class provides custom messages for timeago formatting.
/// {@endtemplate}
class EnCustomShortMessages extends timeago.EnShortMessages
    with TimeAgoLessThanOneMinuteMixin {
  @override
  String secondsText(int seconds) => 'sec.';

  @override
  String lessThanOneMinute(int seconds) => _lessThanOneMinute(seconds);
  @override
  String aboutAMinute(int minutes) => '1 min.';
  @override
  String minutes(int minutes) => '$minutes min.';
  @override
  String aboutAnHour(int minutes) => '~1 h.';
  @override
  String hours(int hours) => '$hours h.';
  @override
  String aDay(int hours) => '~1 d.';
  @override
  String days(int days) => '$days d.';
  @override
  String aboutAMonth(int days) => '~1 mo.';
  @override
  String months(int months) => '$months mo.';
  @override
  String aboutAYear(int year) => '~1 y.';
  @override
  String years(int years) => '$years y.';
}

/// {@template en_custom_short_messages}
/// A custom implementation of the `timeago.EnMessages` class for the English
/// language.
/// This class provides custom messages for timeago formatting.
/// {@endtemplate}
class EnCustomMessages extends timeago.EnMessages
    with TimeAgoLessThanOneMinuteMixin {
  @override
  String secondsText(int seconds) => 'seconds';

  @override
  String lessThanOneMinute(int seconds) => _lessThanOneMinute(seconds);
}

/// {@template en_custom_short_messages}
/// A custom implementation of the `timeago.EnMessages` class for the English
/// language.
/// This class provides custom messages for timeago formatting.
/// {@endtemplate}
class RuCustomMessages extends timeago.RuMessages
    with TimeAgoLessThanOneMinuteMixin {
  @override
  String secondsText(int seconds) => _convert(seconds, 'seconds');

  @override
  String lessThanOneMinute(int seconds) => _lessThanOneMinute(seconds);

  String _convert(int number, String type) {
    final mod = number % 10;
    final modH = number % 100;

    if (mod == 1 && modH != 11) {
      switch (type) {
        case 'seconds':
          return 'секунду';
        default:
          return '';
      }
    } else if (<int>[2, 3, 4].contains(mod) &&
        !<int>[12, 13, 14].contains(modH)) {
      switch (type) {
        case 'seconds':
          return 'секунды';
        default:
          return '';
      }
    }
    switch (type) {
      case 'seconds':
        return 'секунд';
      default:
        return '';
    }
  }
}

/// {@template en_custom_short_messages}
/// A custom implementation of the `timeago.EnMessages` class for the English
/// language.
/// This class provides custom messages for timeago formatting.
/// {@endtemplate}
class RuCustomShortMessages extends timeago.RuShortMessages
    with TimeAgoLessThanOneMinuteMixin {
  @override
  String secondsText(int seconds) => 'с.';

  @override
  String lessThanOneMinute(int seconds) => _lessThanOneMinute(seconds);
}

/// {@template time_ago}
/// Extension on the DateTime class that provides methods for formatting time
/// ago.
///
/// This extension provides two methods:
/// - `timeAgo(BuildContext context)`: Formats the DateTime object as a time ago
/// string.
/// - `timeAgoShort(BuildContext context)`: Formats the DateTime object as a
/// short time ago string.
/// {@endtemplate}
extension TimeAgoExtension on DateTime {
  static const _defaultLocale = 'en';
  static const _supportedLocales = <String>['ru', 'en'];

  static String _getLocaleString(String? value, {required bool short}) {
    final value$ = value ?? _defaultLocale;
    return short ? '${value$}_short' : value$;
  }

  void _initTimeagoLocaleMessages({required bool short}) {
    timeago.LookupMessages? getLocaleLookupMessages(String locale) {
      assert(
        _supportedLocales.contains(locale),
        'The locale "$locale" is not supported.',
      );
      final timeago.LookupMessages defaultLookupMessages =
          short ? EnCustomShortMessages() : EnCustomMessages();

      return switch (locale) {
        'ru' => short ? RuCustomShortMessages() : RuCustomMessages(),
        _ => defaultLookupMessages,
      };
    }

    (String locale, timeago.LookupMessages lookupMessages) getLocale(
      String locale,
    ) =>
        (
          _getLocaleString(locale, short: short),
          getLocaleLookupMessages(locale)!,
        );

    for (final supportedLocale in _supportedLocales) {
      final (locale, lookupMessages) = getLocale(supportedLocale);
      timeago.setLocaleMessages(locale, lookupMessages);
    }
  }

  /// Formats the given DateTime object as a time ago string.
  ///
  /// Returns the formatted time ago string.
  ///
  /// Example usage:
  /// ```dart
  /// final createdAt = ...;
  /// final timeAgoString = createdAt.timeAgo(context);
  /// print(timeAgoString); // Output: '2 days ago'
  /// ```
  String timeAgo(BuildContext context) {
    _initTimeagoLocaleMessages(short: false);

    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays < 6) {
      return timeago.format(this, locale: locale.languageCode);
    } else {
      late DateFormat formatter;
      if (now.year == year) {
        formatter = DateFormat.MMMd(locale.languageCode);
        return formatter.format(this);
      }
      formatter = DateFormat.yMMMd(locale.languageCode);
      return formatter.format(this);
    }
  }

  /// Formats the given DateTime object as a short time ago string.
  ///
  /// Return the formatted short time ago string.
  String timeAgoShort(BuildContext context) {
    _initTimeagoLocaleMessages(short: true);

    final languageCode = Localizations.maybeLocaleOf(context)?.languageCode;
    assert(
      _supportedLocales.contains(languageCode),
      'The locale "$languageCode" is not supported.',
    );
    final locale = _getLocaleString(languageCode, short: true);

    return timeago.format(this, locale: locale);
  }
}
