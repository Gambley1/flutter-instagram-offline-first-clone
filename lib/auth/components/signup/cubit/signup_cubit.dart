import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:form_fields/form_fields.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'signup_state.dart';

/// {@template signup_cubit}
/// Cubit for signup state management. It is used to change signup state from
/// initial to in progress, success or error. It also validates email, password,
/// name, surname and phone number fields.
/// {@endtemplate}
class SignupCubit extends Cubit<SignupState> {
  /// {@macro signup_cubit}
  SignupCubit({
    required UserRepository userRepository,
    required FirebaseNotificationsClient notificationsClient,
  })  : _userRepository = userRepository,
        _notificationsClient = notificationsClient,
        super(const SignupState.initial());

  final UserRepository _userRepository;
  final FirebaseNotificationsClient _notificationsClient;

  /// Changes password visibility, making it visible or not.
  void changePasswordVisibility() => emit(
        state.copyWith(showPassword: !state.showPassword),
      );

  /// Emits initial state of signup screen. It is used to reset state.
  void resetState() => emit(const SignupState.initial());

  /// [Email] value was changed, triggering new changes in state. Checking
  /// whether or not value is valid in [Email] and emmiting new [Email]
  /// validation state.
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

  /// [Email] field was unfocused, here is checking if previous state
  /// with [Email] was valid, in order to indicate it in state after unfocus.
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

  /// [Password] value was changed, triggering new changes in state. Checking
  /// whether or not value is valid in [Password] and emmiting new [Password]
  /// validation state.
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

  /// [Password] field was unfocues. Checking of [Password] validation after
  /// unfocusing and emmit new value of [Password] in state.
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

  /// [FullName] value was changed, triggering new changes in state. Checking
  /// whether or not value is valid in [FullName] and emmiting new [FullName]
  /// validation state.
  void onFullNameChanged(String newValue) {
    final previousScreenState = state;
    final previousFullNameState = previousScreenState.fullName;
    final shouldValidate = previousFullNameState.invalid;
    final newFullNameState = shouldValidate
        ? FullName.validated(
            newValue,
          )
        : FullName.unvalidated(
            newValue,
          );

    final newScreenState = state.copyWith(
      fullName: newFullNameState,
    );

    emit(newScreenState);
  }

  /// [FullName] field was unfocused, here is checking if previous state with
  /// [FullName] was valid, in order to indicate it in state after unfocus.
  void onFullNameUnfocused() {
    final previousScreenState = state;
    final previousFullNameState = previousScreenState.fullName;
    final previousFullNameValue = previousFullNameState.value;

    final newFullNameState = FullName.validated(
      previousFullNameValue,
    );
    final newScreenState = previousScreenState.copyWith(
      fullName: newFullNameState,
    );
    emit(newScreenState);
  }

  /// [Username] value was changed, triggering new changes in state. Checking
  /// whether or not value is valid in [Username] and emmiting new [Username]
  /// validation state.
  void onUsernameChanged(String newValue) {
    final previousScreenState = state;
    final previousUsernameState = previousScreenState.username;
    final shouldValidate = previousUsernameState.invalid;
    final newSurnameState = shouldValidate
        ? Username.validated(
            newValue,
          )
        : Username.unvalidated(
            newValue,
          );

    final newScreenState = state.copyWith(
      username: newSurnameState,
    );

    emit(newScreenState);
  }

  /// [Username] field was unfocues. Checking of [Username] validation after
  /// unfocusing and emmit new value of [Username] in state.
  void onUsernameUnfocused() {
    final previousScreenState = state;
    final previousUsernameState = previousScreenState.username;
    final previousUsernameValue = previousUsernameState.value;

    final newUsernameState = Username.validated(
      previousUsernameValue,
    );
    final newScreenState = previousScreenState.copyWith(
      username: newUsernameState,
    );
    emit(newScreenState);
  }

  /// Defines method to submit form. It is used to check if all inputs are valid
  /// and if so, it is used to signup user.
  Future<void> onSubmit({
    File? avatarFile,
  }) async {
    final email = Email.validated(state.email.value);
    final password = Password.validated(state.password.value);
    final fullName = FullName.validated(state.fullName.value);
    final username = Username.validated(state.username.value);
    final isFormValid =
        FormzValid([email, password, fullName, username]).isFormValid;

    final newState = state.copyWith(
      email: email,
      password: password,
      fullName: fullName,
      username: username,
      submissionStatus: isFormValid ? SignupSubmissionStatus.inProgress : null,
    );

    emit(newState);

    if (!isFormValid) return;

    try {
      String? imageUrlResponse;
      if (avatarFile != null) {
        final imageBytes =
            await PickImage().imageBytes(file: File(avatarFile.path));
        final avatarsStorage = Supabase.instance.client.storage.from('avatars');

        final fileExt = avatarFile.path.split('.').last.toLowerCase();
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
        final filePath = fileName;
        await avatarsStorage.uploadBinary(
          filePath,
          imageBytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExt',
            cacheControl: '360000',
          ),
        );
        imageUrlResponse = await avatarsStorage.createSignedUrl(
          filePath,
          60 * 60 * 24 * 365 * 10,
        );
      }

      final pushToken = await _notificationsClient.getToken();

      await _userRepository.signUpWithPassword(
        email: email.value,
        password: password.value,
        fullName: fullName.value,
        username: username.value,
        avatarUrl: imageUrlResponse,
        pushToken: pushToken,
      );

      if (isClosed) return;
      emit(state.copyWith(submissionStatus: SignupSubmissionStatus.success));
    } catch (e, stackTrace) {
      _errorFormatter(e, stackTrace);
    }
  }

  /// Defines method to format error. It is used to format error in order to
  /// show it to user.
  void _errorFormatter(Object e, StackTrace stackTrace) {
    logE(e.toString());
    addError(e, stackTrace);

    SignupSubmissionStatus submissionStatus() {
      return SignupSubmissionStatus.error;
    }

    final newState = state.copyWith(
      submissionStatus: submissionStatus(),
    );
    emit(newState);
  }
}
