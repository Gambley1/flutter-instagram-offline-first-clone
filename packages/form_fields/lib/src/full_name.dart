import 'package:equatable/equatable.dart' show EquatableMixin;
import 'package:flutter/foundation.dart' show immutable;
import 'package:form_fields/src/formz_input_field.dart';
import 'package:formz/formz.dart' show FormzInput;

/// {@template full_name}
/// Form input for a full name. It extends [FormzInput] and uses
/// [FullNameValidationError] for its validation errors.
/// {@endtemplate}
@immutable
class FullName extends FormzInput<String, FullNameValidationError>
    with EquatableMixin, FormzValidationMixin {
  /// {@macro full_name.unvalidated}
  const FullName.unvalidated([
    super.value = '',
  ]) : super.pure();

  /// {@macro full_name.validated}
  const FullName.validated(super.value) : super.dirty();

  // static final _nameRegex = RegExp(r'^[A-Z][a-zA-Z]*(?: [A-Z][a-zA-Z]*)?$');

  @override
  FullNameValidationError? validator(String value) {
    if (value.isEmpty) return FullNameValidationError.empty;
    // if (!_nameRegex.hasMatch(value)) return FullNameValidationError.invalid;
    return null;
  }

  @override
  Map<FullNameValidationError?, String?> get validationErrorMessage => {
        FullNameValidationError.empty: 'This field is required',
        FullNameValidationError.invalid: 'Full name is incorrect',
        null: null,
      };

  @override
  List<Object?> get props => [value, pure];
}

/// Validation errors for [FullName]. It can be empty or invalid.
enum FullNameValidationError {
  /// Empty full name.
  empty,

  /// Invalid full name.
  invalid,
}
