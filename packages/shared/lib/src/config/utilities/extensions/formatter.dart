/*
 * ----------------------------------------------------------------------------
 *
 * This file is part of the metal_bonus_backend project, available at:
 * https://github.com/Gambley1/metal_bonus_backend/
 *
 * Created by: Emil Zulufov
 * ----------------------------------------------------------------------------
 *
 * Copyright (c) 2020 Emil Zulufov
 *
 * Licensed under the MIT License.
 *
 * ----------------------------------------------------------------------------
*/

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// {@template formatter}
/// A class that contains a number of formatters.
/// {@endtemplate}
class Formatters {
  /// {@macro formatters}
  Formatters({
    required BuildContext context,
    DateFormat Function(String locale)? dateFormat,
  })  : formatter = NumberFormat.decimalPattern(
          Localizations.localeOf(context).languageCode,
        ),
        currency = NumberFormat.currency(
          symbol:
              Localizations.localeOf(context).languageCode == 'en' ? r'$' : '₸',
          decimalDigits: 0,
          locale: Localizations.localeOf(context).languageCode,
        ),
        date = dateFormat?.call(Localizations.localeOf(context).languageCode) ??
            DateFormat(
              'HH:mm - dd.MM.yyyy',
              Localizations.localeOf(context).languageCode,
            );

  /// The [NumberFormat] formatter.
  final NumberFormat formatter;

  /// The [NumberFormat] currency formatter.
  final NumberFormat currency;

  /// The [DateFormat] date formatter.
  final DateFormat date;
}

Formatters _formatters(
  BuildContext context, {
  DateFormat Function(String locale)? dateFormat,
}) =>
    Formatters(context: context, dateFormat: dateFormat);

/// Extension for parsing [String] to [num].
extension Parse on String {
  /// Parses [String] to [num].
  num get parse => isEmpty ? 0 : NumberFormat().parse(clearValue);
}

/// Extension for formatting [String].
extension FormatString on String {
  /// Formats [num] to [String].
  String format({required BuildContext context, bool separate = true}) =>
      separate ? _formatters(context).formatter.format(parse) : this;

  /// Formats [num] to [String].
  num formatToNum({required BuildContext context, bool separate = true}) =>
      format(separate: separate, context: context).parse;

  /// Returns [String] or empty string if it is null.
  String get stringOrEmpty => isEmpty ? '' : this;

  /// Returns [String] or 0 if it is null.
  String get stringOrZero => isEmpty ? '0' : this;

  /// Returns [String] with currency symbol.
  String currencyFormat({
    required BuildContext context,
  }) =>
      _formatters(context)
          .currency
          .format(formatToNum(context: context, separate: false));

  /// Displays loading string if [isLoading] is true.
  String isLoadingString({bool isLoading = false}) => isLoading ? '...' : this;
}

/// Extension for formatting [num] to [String].
extension FormatNum on num {
  /// Formats [num] to [String].
  String format({required BuildContext context, bool separate = true}) =>
      separate ? _formatters(context).formatter.format(this) : toString();

  /// Returns [String] with currency symbol.
  String currencyFormat(BuildContext context) =>
      _formatters(context).currency.format(this);
}

/// Extension for formatting [num] to [String].
extension FormatNullable on num? {
  /// Formats [num] to [String].
  String? formatNullable({
    required BuildContext context,
    bool separate = true,
  }) =>
      separate ? _formatters(context).formatter.format(this) : null;

  /// Returns [num] or 0 if it is null.
  num get numberOrZero => this ?? 0;

  /// Returns [String] with currency symbol.
  String currencyFormat({required BuildContext context}) =>
      _formatters(context).currency.format(this);
}

/// Extension for removing all non-digit characters from a string.
extension ClearValue on String {
  /// Removes all non-digits from string.
  String get clearValue => replaceAll(RegExp(r'[^\d]'), '');

  /// Replaces from string given [symbol] to empty ' ' space.
  String replaceWithEmptySpace(String symbol) => replaceAll(symbol, ' ');

  /// Removes all special characters from a String
  String removeSpecialCharacters({
    bool keepAllowed = false,
  }) {
    if (keepAllowed) {
      // Use allowed chars RegExp to keep only allowed characters
      return replaceAll(RegExp(r'[^\w\-_.+]', multiLine: true), '');
    } else {
      // Use different RegExp for basic alphanumeric only
      return replaceAll(RegExp(r'[^\w]+', multiLine: true), '');
    }
  }
}

/// Extension for formatting [DateTime] to [String].
extension DateFormatter on DateTime {
  /// Formats [DateTime] to [String].
  String format(
    BuildContext context, {
    DateFormat Function(String locale)? dateFormat,
  }) =>
      _formatters(context, dateFormat: dateFormat).date.format(this);
}

/// Compacts big numbers.
extension CompactFormatter on num {
  /// From 1,200,000 to 1,2 million.
  String compact(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final compactFormatter =
        NumberFormat.compactLong(locale: locale.languageCode);
    return this <= 9999
        ? format(context: context).replaceWithEmptySpace(',')
        : compactFormatter.format(this).replaceAll('.', ',');
  }

  /// From 1,200,000 to 1,2M.
  String compactShort(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final compactFormatter = NumberFormat.compact(locale: locale.languageCode);
    return this <= 9999
        ? format(context: context)
        : compactFormatter.format(this).replaceAll('.', ',');
  }
}

/// Extension for converting [String] to snake case.
extension ConvertToSnakeCase on String {
  /// Converts [String] to snake case.
  String get convertToSnakeCase {
    final output = StringBuffer();
    final length = this.length;

    for (var i = 0; i < length; i++) {
      final char = this[i];

      if (char == char.toUpperCase() && i > 0) {
        output.write('_');
      }

      output.write(char.toLowerCase());
    }

    return output.toString();
  }
}
