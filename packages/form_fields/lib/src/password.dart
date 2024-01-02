import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:formz/formz.dart' show FormzInput;

/// {@template password}
/// Form input for a password. It extends [FormzInput] and uses
/// [PasswordValidationError] for its validation errors.
/// {@endtemplate}
@immutable
class Password extends FormzInput<String, PasswordValidationError>
    with EquatableMixin {
  /// {@macro password}
  const Password.unvalidated([
    super.value = '',
  ]) : super.pure();

  /// {@macro password}
  const Password.validated([
    super.value = '',
  ]) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    } else if (value.length < 6 || value.length > 120) {
      return PasswordValidationError.invalid;
    } else {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        value,
        pure,
      ];
}

/// Validation errors for [Password]. It can be empty or invalid.
enum PasswordValidationError {
  /// Empty password.
  empty,

  /// Invalid password.
  invalid,
}

/// Password validation errors message
Map<PasswordValidationError?, String?> get passwordValidationErrorMessage => {
      PasswordValidationError.empty: 'This field is required',
      PasswordValidationError.invalid:
          'Password should contain at least 6 characters',
      null: null,
    };
