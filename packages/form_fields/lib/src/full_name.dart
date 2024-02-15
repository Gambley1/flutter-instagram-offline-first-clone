import 'package:equatable/equatable.dart' show EquatableMixin;
import 'package:flutter/foundation.dart' show immutable;
import 'package:formz/formz.dart' show FormzInput;

/// {@template name}
/// Form input for a name. It extends [FormzInput] and uses
/// [FullNameValidationError] for its validation errors.
/// {@endtemplate}
@immutable
class FullName extends FormzInput<String, FullNameValidationError>
    with EquatableMixin {
  /// {@macro name}
  const FullName.unvalidated([
    super.value = '',
  ]) : super.pure();

  /// {@macro name}
  const FullName.validated(super.value) : super.dirty();

  // static final _nameRegex = RegExp(r'^[A-Z][a-zA-Z]*(?: [A-Z][a-zA-Z]*)?$');

  @override
  FullNameValidationError? validator(String value) {
    if (value.isEmpty) return FullNameValidationError.empty;
    // if (!_nameRegex.hasMatch(value)) return FullNameValidationError.invalid;
    return null;
  }

  @override
  List<Object?> get props => [
        value,
        pure,
      ];
}

/// Validation errors for [FullName]. It can be empty or invalid.
enum FullNameValidationError {
  /// Empty name.
  empty,

  /// Invalid name.
  invalid,
}

/// Full name validation errors message
Map<FullNameValidationError?, String?> get fullNameValidationErrorMessage => {
      FullNameValidationError.empty: 'This field is required',
      FullNameValidationError.invalid:
          'Full name should start with an uppercase '
              'letter and can contain multiple names separated by a space. '
              'Only letters are allowed.',
      null: null,
    };
