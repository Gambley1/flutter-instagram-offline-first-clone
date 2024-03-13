import 'package:equatable/equatable.dart' show EquatableMixin;
import 'package:flutter/foundation.dart' show immutable;
import 'package:form_fields/src/formz_input_field.dart';
import 'package:formz/formz.dart';

/// {@template otp}
/// Formz input for OTP. It can be empty or invalid.
/// {@endtemplate}
@immutable
class Otp extends FormzInput<String, OtpValidationError>
    with EquatableMixin, FormzValidationMixin {
  /// {@macro otp.unvalidated}
  const Otp.unvalidated([super.value = '']) : super.pure();

  /// {@macro otp.validated}
  const Otp.validated(super.value) : super.dirty();

  static final _otpRegex = RegExp(r'^[0-9]+$');

  @override
  OtpValidationError? validator(String value) {
    return value.isEmpty
        ? OtpValidationError.empty
        : (_otpRegex.hasMatch(value) ? null : OtpValidationError.invalid);
  }

  @override
  Map<OtpValidationError?, String?> get validationErrorMessage => {
        OtpValidationError.empty:
            'OTP cannot be empty. Please enter your code.',
        OtpValidationError.invalid:
            'Invalid OTP. Please check and re-enter the code.',
        null: null,
      };

  @override
  List<Object> get props => [pure, value];
}

/// Validation errors for [Otp]. It can be empty or invalid.
enum OtpValidationError {
  /// Empty OTP.
  empty,

  /// Invalid OTP.
  invalid,
}
