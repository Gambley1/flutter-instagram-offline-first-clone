import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:form_fields/form_fields.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'login_state.dart';

/// {@template login_cubit}
/// Cubit for login state management. It is used to change login state from
/// initial to in progress, success or error. It also validates email and
/// password fields.
/// {@endtemplate}
class LoginCubit extends Cubit<LoginState> {
  /// {@macro login_cubit}
  LoginCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(
          const LoginState.initial(),
        );

  final UserRepository _userRepository;

  /// Changes password visibility, making it visible or not.
  void changePasswordVisibility() => emit(
        state.copyWith(showPassword: !state.showPassword),
      );

  /// Emits initial state of login screen.
  void resetState() => emit(const LoginState.initial());

  /// Email value was changed, triggering new changes in state.
  void onEmailChanged(String newValue) {
    final previousScreenState = state;
    final previousEmailState = previousScreenState.email;
    final shouldValidate = previousEmailState.invalid;
    final newEmailState = shouldValidate
        ? Email.validated(
            newValue,
          )
        : Email.unvalidated(
            newValue,
          );

    final newScreenState = state.copyWith(
      email: newEmailState,
    );

    emit(newScreenState);
  }

  /// Email field was unfocused, here is checking if previous state with email
  /// was valid, in order to indicate it in state after unfocus.
  void onEmailUnfocused() {
    final previousScreenState = state;
    final previousEmailState = previousScreenState.email;
    final previousEmailValue = previousEmailState.value;

    final newEmailState = Email.validated(
      previousEmailValue,
    );
    final newScreenState = previousScreenState.copyWith(
      email: newEmailState,
    );
    emit(newScreenState);
  }

  /// Password value was changed, triggering new changes in state.
  /// Checking whether or not value is valid in [Password] and emmiting new
  /// [Password] validation state.
  void onPasswordChanged(String newValue) {
    final previousScreenState = state;
    final previousPasswordState = previousScreenState.password;
    final shouldValidate = previousPasswordState.invalid;
    final newPasswordState = shouldValidate
        ? Password.validated(
            newValue,
          )
        : Password.unvalidated(
            newValue,
          );

    final newScreenState = state.copyWith(
      password: newPasswordState,
    );

    emit(newScreenState);
  }

  /// Password field was unfocues. Checking of [Password] validation after unfo-
  /// cusing and emmit new value of [Password] in state.
  void onPasswordUnfocused() {
    final previousScreenState = state;
    final previousPasswordState = previousScreenState.password;
    final previousPasswordValue = previousPasswordState.value;

    final newPasswordState = Password.validated(
      previousPasswordValue,
    );
    final newScreenState = previousScreenState.copyWith(
      password: newPasswordState,
    );
    emit(newScreenState);
  }

  /// Makes whole login state initial, as [Email] and [Password] becomes unvalid
  /// and [LoginSubmissionStatus] becomes idle. Solely used if during login
  /// user switched on sign up, therefore login state does not persists and
  /// becomes initial again.
  void idle() {
    const initalState = LoginState.initial();
    emit(initalState);
  }

  Future<void> loginWithGoogle() async {
    try {
      await _userRepository.logInWithGoogle();
    } catch (error, stackTrace) {
      _errorFormatter(error, stackTrace);
    }
  }

  /// Taking into account current [Email] and [Password] state, checking its
  /// value and validates it, in order to check if form itself valid
  /// to proccess to login, in order to prevent invalid user authorizing
  /// with unvalid email and password, not making unnecessary network request.
  /// After checking, procced to login network request.
  Future<void> onSubmit() async {
    final email = Email.validated(state.email.value);
    final password = Password.validated(state.password.value);
    final isFormValid = FormzValid([email, password]).isFormValid;

    final newState = state.copyWith(
      email: email,
      password: password,
      status: isFormValid ? LoginSubmissionStatus.inProgress : null,
    );

    emit(newState);

    if (!isFormValid) return;

    try {
      await _userRepository.logInWithPassword(
        email: email.value,
        password: password.value,
      );
      final newState = state.copyWith(status: LoginSubmissionStatus.success);
      emit(newState);
    } catch (e, stackTrace) {
      _errorFormatter(e, stackTrace);
    }
  }

  /// Formats error, that occured during login process.
  void _errorFormatter(Object e, StackTrace stackTrace) {
    logE('Failed to login.', error: e, stackTrace: stackTrace);
    addError(e, stackTrace);
    LoginSubmissionStatus status() {
      if (e is AuthException) {
        if (e.statusCode != null) {
          if (e.statusCode?.parse == 400) {
            return LoginSubmissionStatus.invalidCredentials;
          }
        }
      }
      return LoginSubmissionStatus.error;
    }

    final newState = state.copyWith(
      status: status(),
      message: e.toString(),
    );
    emit(newState);
  }
}
