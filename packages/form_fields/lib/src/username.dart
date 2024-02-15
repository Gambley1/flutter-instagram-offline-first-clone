import 'package:equatable/equatable.dart' show EquatableMixin;
import 'package:flutter/foundation.dart' show immutable;
import 'package:formz/formz.dart' show FormzInput;

/// {@template name}
/// Form input for a name. It extends [FormzInput] and uses
/// [UsernameValidationError] for its validation errors.
/// {@endtemplate}
@immutable
class Username extends FormzInput<String, UsernameValidationError>
    with EquatableMixin {
  /// {@macro name}
  const Username.unvalidated([
    super.value = '',
  ]) : super.pure();

  /// {@macro name}
  const Username.validated(super.value) : super.dirty();

  static final _nameRegex = RegExp(r'^[a-zA-Z0-9_.]{3,16}$');

  @override
  UsernameValidationError? validator(String value) {
    if (value.isEmpty) return UsernameValidationError.empty;
    if (!_nameRegex.hasMatch(value)) return UsernameValidationError.invalid;
    return null;
  }

  @override
  List<Object?> get props => [
        value,
        pure,
      ];
}

/// Validation errors for [Username]. It can be empty or invalid.
enum UsernameValidationError {
  /// Empty name.
  empty,

  /// Invalid name.
  invalid,
}

/// Password validation errors message
Map<UsernameValidationError?, String?> get usernameValidationErrorMessage => {
      UsernameValidationError.empty: 'This field is required',
      UsernameValidationError.invalid: 'Pasword should contain only letters, '
          'numbers, and underscores, and be between '
          '3 and 16 characters in length.',
      null: null,
    };
