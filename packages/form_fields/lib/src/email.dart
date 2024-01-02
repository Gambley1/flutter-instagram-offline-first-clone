import 'package:equatable/equatable.dart' show EquatableMixin;
import 'package:flutter/foundation.dart' show immutable;
import 'package:formz/formz.dart';

/// {@template email}
/// Formz input for email. It can be empty, invalid or already registered.
/// {@endtemplate}
@immutable
class Email extends FormzInput<String, EmailValidationError>
    with EquatableMixin {
  /// {@macro email}
  const Email.unvalidated([super.value = ''])
      : isAlreadyRegistered = false,
        super.pure();

  /// {@macro email}
  const Email.validated(super.value)
      : isAlreadyRegistered = false,
        super.dirty();

  static final _emailRegex = RegExp(
    r'^(([\w-]+\.)+[\w-]+|([a-zA-Z]|[\w-]{2,}))@((([0-1]?'
    r'[0-9]{1,2}|25[0-5]|2[0-4][0-9])\.([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])\.'
    r'([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])\.([0-1]?[0-9]{1,2}|25[0-5]|2[0-4][0-9])'
    r')|([a-zA-Z]+[\w-]+\.)+[a-zA-Z]{2,4})$',
  );

  /// Indicates if email is already registered.
  final bool isAlreadyRegistered;

  @override
  EmailValidationError? validator(String value) {
    return value.isEmpty
        ? EmailValidationError.empty
        : (isAlreadyRegistered
            ? EmailValidationError.alreadyRegistered
            : (_emailRegex.hasMatch(value)
                ? null
                : EmailValidationError.invalid));
  }

  @override
  List<Object> get props => [
        pure,
        value,
        isAlreadyRegistered,
      ];
}

/// Validation errors for [Email]. It can be empty, invalid or already
/// registered.
enum EmailValidationError {
  /// Empty email.
  empty,

  /// Invalid email.
  invalid,

  /// Email already registered.
  alreadyRegistered,
}

/// Email validation errors message
Map<EmailValidationError?, String?> get emailValidationErrorMessage => {
      EmailValidationError.empty: 'This field is required',
      EmailValidationError.invalid: 'Email is not correct',
      EmailValidationError.alreadyRegistered:
          'Email is already registered, try another',
      null: null,
    };
