import 'package:flutter/material.dart';

/// {@template text_style_extension}
/// TextStyle extension that provides access to [ThemeData] and [TextTheme].
/// {@endtemplate}
extension TextStyleExtension on BuildContext {
  /// Returns [ThemeData] from [Theme.of].
  ThemeData get theme => Theme.of(this);

  /// Returns [TextTheme] from [Theme.of]
  TextTheme get textTheme => theme.textTheme;

  /// Material body large text style.
  TextStyle? get bodyLarge => textTheme.bodyLarge;

  /// Material body medium text style.
  TextStyle? get bodyMedium => textTheme.bodyMedium;

  /// Material body small text style.
  TextStyle? get bodySmall => textTheme.bodySmall;

  /// Material display large text style.
  TextStyle? get displayLarge => textTheme.displayLarge;

  /// Material display medium text style.
  TextStyle? get displayMedium => textTheme.displayMedium;

  /// Material display small text style.
  TextStyle? get displaySmall => textTheme.displaySmall;

  /// Material headline large text style.
  TextStyle? get headlineLarge => textTheme.headlineLarge;

  /// Material headline medium text style.
  TextStyle? get headlineMedium => textTheme.headlineMedium;

  /// Material headline small text style.
  TextStyle? get headlineSmall => textTheme.headlineSmall;

  /// Material label large text style.
  TextStyle? get labelLarge => textTheme.labelLarge;

  /// Material label medium text style.
  TextStyle? get labelMedium => textTheme.labelMedium;

  /// Material label small text style.
  TextStyle? get labelSmall => textTheme.labelSmall;

  /// Material title large text style.
  TextStyle? get titleLarge => textTheme.titleLarge;

  /// Material title medium text style.
  TextStyle? get titleMedium => textTheme.titleMedium;

  /// Material title small text style.
  TextStyle? get titleSmall => textTheme.titleSmall;
}
