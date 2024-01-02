import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';
import 'package:timeago/timeago.dart' as timeago;

class EnCustomShortMessages extends timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'now';
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
  @override
  String wordSeparator() => ' ';
}

extension TimeAgo on DateTime {
  String timeAgo(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays < 6) {
      return timeago.format(this, locale: locale.languageCode);
      // if (difference.inSeconds < 60) {
      //   final seconds = difference.inSeconds;
      //   return context.l10n.secondsAgo(seconds);
      // } else if (difference.inMinutes < 60) {
      //   final minutes = difference.inMinutes;
      //   return context.l10n.minutesAgo(minutes);
      // } else if (difference.inHours < 24) {
      //   final hours = difference.inHours;
      //   return context.l10n.hoursAgo(hours);
      // } else {
      //   final days = difference.inDays;
      //   return context.l10n.daysAgo(days);
      // }
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

  String timeAgoShort(BuildContext context) {
    timeago.setLocaleMessages('ru_short', timeago.RuShortMessages());
    timeago.setLocaleMessages('en_custom_short', EnCustomShortMessages());

    final languageCode = Localizations.localeOf(context).languageCode;
    final locale = languageCode == 'en' ? 'en_custom_short' : 'ru_short';

    return timeago.format(this, locale: locale);
  }
}
