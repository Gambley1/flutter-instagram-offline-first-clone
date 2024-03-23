import 'package:formz/formz.dart';

/// Mixin on [FormzInput] that provides common functionality for form input
/// fields.
///
/// It has:
/// - [validationError] getter that returns a validation error if input is
///  invalid
/// - [errorMessage] getter that returns an error message based on [E]
/// - [validationErrorMessage] map that contains error messages for each [E]
mixin FormzValidationMixin<T, E> on FormzInput<T, E> {
  /// Returns the validation error if the input is invalid.
  E? get validationError => invalid ? error : null;

  /// Returns email error text based on [E].
  String? get errorMessage => validationErrorMessage[validationError];

  /// Email validation errors message
  Map<E?, String?> get validationErrorMessage;
}
