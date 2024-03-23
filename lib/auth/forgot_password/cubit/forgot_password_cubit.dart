import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:form_fields/form_fields.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const ForgotPasswordState.initial());

  final UserRepository _userRepository;

  /// Emits initial state of login screen.
  void resetState() => emit(const ForgotPasswordState.initial());

  /// Email value was changed, triggering new changes in state.
  void onEmailChanged(String newValue) {
    final previousScreenState = state;
    final previousEmailState = previousScreenState.email;
    final shouldValidate = previousEmailState.invalid;
    final newEmailState = shouldValidate
        ? Email.dirty(
            newValue,
          )
        : Email.pure(
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

    final newEmailState = Email.dirty(
      previousEmailValue,
    );
    final newScreenState = previousScreenState.copyWith(
      email: newEmailState,
    );
    emit(newScreenState);
  }

  Future<void> onSubmit({
    VoidCallback? onSuccess,
  }) async {
    final email = Email.dirty(state.email.value);
    final isFormValid = FormzValid([email]).isFormValid;

    final newState = state.copyWith(
      email: email,
      status: isFormValid ? ForgotPasswordStatus.loading : null,
    );

    emit(newState);

    if (!isFormValid) return;

    try {
      await _userRepository.sendPasswordResetEmail(email: state.email.value);
      final newState = state.copyWith(status: ForgotPasswordStatus.success);
      if (isClosed) return;
      emit(newState);
      onSuccess?.call();
    } catch (error, stackTrace) {
      _errorFormatter(error, stackTrace);
    }
  }

  void _errorFormatter(Object error, StackTrace stackTrace) {
    addError(error, stackTrace);
    final status = switch (error) {
      AuthException(:final statusCode) => switch (statusCode?.parse) {
          HttpStatus.tooManyRequests => ForgotPasswordStatus.tooManyRequests,
          _ => ForgotPasswordStatus.failure,
        },
      _ => ForgotPasswordStatus.failure,
    };

    emit(state.copyWith(status: status));
  }
}
