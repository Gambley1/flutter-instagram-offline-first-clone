part of 'login_cubit.dart';

/// [LoginErrorMessage] is a type alias for [String] that is used to indicate
/// error message, that will be shown to user, when he will try to submit login
/// form, but there is an error occured. It is used to show user, what exactly
/// went wrong.
typedef LoginErrorMessage = String;

/// [LoginState] submission status, indicating current state of user loginng in.
enum LoginSubmissionStatus {
  /// [LoginSubmissionStatus.idle] indicates that user has not yet submitted
  /// login form.
  idle,

  /// [LoginSubmissionStatus.inProgress] indicates that user has submitted
  /// login form and is currently waiting for response from backend.
  inProgress,

  /// [LoginSubmissionStatus.success] indicates that user has successfully
  /// submitted login form and is currently waiting for response from backend.
  success,

  /// [LoginSubmissionStatus.invalidCredentials] indicates that user has
  /// submitted login form with invalid credentials.
  invalidCredentials,

  /// [LoginSubmissionStatus.userNotFound] indicates that user with provided
  /// credentials was not found in database.
  userNotFound,

  /// [LoginSubmissionStatus.inProgress] indicates that user has no iternet
  /// connection,during network request.
  networkError,

  /// [LoginSubmissionStatus.error] indicates that something unexpected happen.
  error,
}

/// Extension on [LoginSubmissionStatus] that checks current status.
extension SubmissionStatusX on LoginSubmissionStatus {
  /// Checks if current submission status is success.
  bool get isSuccess => this == LoginSubmissionStatus.success;

  /// Checks if current submission status is in progress.
  bool get isLoading => this == LoginSubmissionStatus.inProgress;

  /// Checks if current submission status is invalid credentials.
  bool get isInvalidCredentials =>
      this == LoginSubmissionStatus.invalidCredentials;

  /// Checks if current submission status is network error.
  bool get isNetworkError => this == LoginSubmissionStatus.networkError;

  /// Checks if current submission status is user not found.
  bool get isUserNotFound => this == LoginSubmissionStatus.userNotFound;

  /// Checks if current submission status is error.
  bool get isError =>
      this == LoginSubmissionStatus.error ||
      isUserNotFound ||
      isNetworkError ||
      isInvalidCredentials;
}

/// Extension on [LoginSubmissionStatus] that returns associated error message.
/// If there is no error message associated with current submission status,
/// returns empty string.
extension FormFieldsValidationErrorExtension on LoginState {
  /// Returns associated [EmailValidationError] or null.
  EmailValidationError? get _emailValidationError =>
      email.invalid ? email.error : null;

  /// Returns associated [PasswordValidationError] or null.
  PasswordValidationError? get _passwordValidationError =>
      password.invalid ? password.error : null;
}

/// For each form field in [LoginState] returns associated `error` text based on
/// form field validation error. If validation error is `null` returns `null`,
/// meaning that there is no error in form field.
extension FormFieldsTextErrorExtension on LoginState {
  /// Returns email error text based on [EmailValidationError].
  String? get emailError => emailValidationErrorMessage[_emailValidationError];

  /// Returns password error text based on [PasswordValidationError].
  String? get passwordError =>
      passwordValidationErrorMessage[_passwordValidationError];
}

/// {@template login_state}
/// [LoginState] holds all the information related to user login process.
/// It is used to determine current state of user login process, and to
/// validate user inputed data.
/// {@endtemplate}
class LoginState {
  /// {@macro login_state}
  const LoginState._({
    required this.status,
    required this.message,
    required this.showPassword,
    required this.email,
    required this.password,
  });

  /// Initial login state.
  const LoginState.initial()
      : this._(
          status: LoginSubmissionStatus.idle,
          message: '',
          showPassword: false,
          email: const Email.unvalidated(),
          password: const Password.unvalidated(),
        );

  /// Submission status, used to indicate current login state.
  final LoginSubmissionStatus status;

  /// Error message, thrown during network request or user wrong enteractions.
  final LoginErrorMessage message;

  /// Solely used to show or hide password.
  final bool showPassword;

  /// [Email] that makes it easy to validate inputed by user value of it.
  final Email email;

  /// [Password] makes it easy to validate inputed by user value of password.
  final Password password;

  /// Copywith method to make it possible to clone or duplicate current login
  /// state to make mutations and persist other parameters.
  LoginState copyWith({
    LoginSubmissionStatus? status,
    LoginErrorMessage? message,
    bool? showPassword,
    Email? email,
    Password? password,
  }) {
    return LoginState._(
      status: status ?? this.status,
      message: message ?? this.message,
      showPassword: showPassword ?? this.showPassword,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

final loginSubmissionStatusMessage =
    <LoginSubmissionStatus, SubmissionStatusMessage>{
  LoginSubmissionStatus.error: const SubmissionStatusMessage.genericError(),
  LoginSubmissionStatus.networkError:
      const SubmissionStatusMessage.networkError(),
  LoginSubmissionStatus.invalidCredentials: const SubmissionStatusMessage(
    title: 'Email and/or password are incorrect.',
  ),
  LoginSubmissionStatus.userNotFound: const SubmissionStatusMessage(
    title: 'User with this email not found!',
    description: 'Try to sign up.',
  ),
};
