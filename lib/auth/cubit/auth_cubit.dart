import 'package:bloc/bloc.dart';

/// {@template auth_cubit}
/// Cubit for auth state management. It is used to change auth from login to
/// signup or reversed.
/// {@endtemplate}
class AuthCubit extends Cubit<bool> {
  /// {@macro cubit}
  AuthCubit() : super(true);

  /// Defines method to change auth from login to signup or reversed.
  void changeAuth({required bool showLogin}) => emit(showLogin);
}
