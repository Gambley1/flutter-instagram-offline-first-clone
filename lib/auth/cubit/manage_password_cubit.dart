import 'package:bloc/bloc.dart';

/// {@template manage_password_cubit}
/// Changes screen from forgot to change password or reversed.
/// {@endtemplate}
class ManagePasswordCubit extends Cubit<bool> {
  /// {@macro manage_password_cubit}
  ManagePasswordCubit() : super(true);

  /// Defines method to change screen from forgot to change password or
  /// reversed.
  void changeScreen({required bool showForgotPassword}) =>
      emit(showForgotPassword);
}
