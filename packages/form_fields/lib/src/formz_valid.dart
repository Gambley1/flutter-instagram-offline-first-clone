import 'package:formz/formz.dart';

/// {@template formz_valid}
/// Formz input for valid state. It is used to check if all inputs are valid.
/// It is used in [FormzInput] as a generic type.
/// {@endtemplate}
class FormzValid with FormzMixin {
  /// {@macro formz_valid}
  FormzValid(List<FormzInput<dynamic, dynamic>> inputs) : _inputs = inputs;

  final List<FormzInput<dynamic, dynamic>> _inputs;

  /// Returns `true` if all inputs are valid. Otherwise, returns `false`.
  bool get isFormValid => status == FormzStatus.valid;

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => _inputs;
}
