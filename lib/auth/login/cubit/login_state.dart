part of 'login_cubit.dart';

/// [LoginErrorMessage] is a type alias for [String] that is used to indicate
/// error message, that will be shown to user, when he will try to submit login
/// form, but there is an error occured. It is used to show user, what exactly
/// went wrong.
typedef LoginErrorMessage = String;

/// [LoginState] submission status, indicating current state of user loginng in.
enum LogInSubmissionStatus {
  /// [LogInSubmissionStatus.idle] indicates that user has not yet submitted
  /// login form.
  idle,

  /// [LogInSubmissionStatus.loading] indicates that user has submitted
  /// login form and is currently waiting for response from backend.
  loading,

  /// [LogInSubmissionStatus.googleAuthInProgress] indicates that user has
  /// submitted login with google.
  googleAuthInProgress,

  /// [LogInSubmissionStatus.githubAuthInProgress] indicates that user has
  /// submitted login with github.
  githubAuthInProgress,

  /// [LogInSubmissionStatus.success] indicates that user has successfully
  /// submitted login form and is currently waiting for response from backend.
  success,

  /// [LogInSubmissionStatus.invalidCredentials] indicates that user has
  /// submitted login form with invalid credentials.
  invalidCredentials,

  /// [LogInSubmissionStatus.userNotFound] indicates that user with provided
  /// credentials was not found in database.
  userNotFound,

  /// [LogInSubmissionStatus.loading] indicates that user has no iternet
  /// connection,during network request.
  networkError,

  /// [LogInSubmissionStatus.error] indicates that something unexpected happen.
  error,

  /// [LogInSubmissionStatus.googleLogInFailure] indicates that some went
  /// wrong during google login process.
  googleLogInFailure;

  bool get isSuccess => this == LogInSubmissionStatus.success;
  bool get isLoading => this == LogInSubmissionStatus.loading;
  bool get isGoogleAuthInProgress =>
      this == LogInSubmissionStatus.googleAuthInProgress;
  bool get isGithubAuthInProgress =>
      this == LogInSubmissionStatus.githubAuthInProgress;
  bool get isInvalidCredentials =>
      this == LogInSubmissionStatus.invalidCredentials;
  bool get isNetworkError => this == LogInSubmissionStatus.networkError;
  bool get isUserNotFound => this == LogInSubmissionStatus.userNotFound;
  bool get isError =>
      this == LogInSubmissionStatus.error ||
      isUserNotFound ||
      isNetworkError ||
      isInvalidCredentials;
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
          status: LogInSubmissionStatus.idle,
          message: '',
          showPassword: false,
          email: const Email.pure(),
          password: const Password.pure(),
        );

  /// Submission status, used to indicate current login state.
  final LogInSubmissionStatus status;

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
    LogInSubmissionStatus? status,
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
    <LogInSubmissionStatus, SubmissionStatusMessage>{
  LogInSubmissionStatus.error: const SubmissionStatusMessage.genericError(),
  LogInSubmissionStatus.networkError:
      const SubmissionStatusMessage.networkError(),
  LogInSubmissionStatus.invalidCredentials: const SubmissionStatusMessage(
    title: 'Email and/or password are incorrect.',
  ),
  LogInSubmissionStatus.userNotFound: const SubmissionStatusMessage(
    title: 'User with this email not found!',
    description: 'Try to sign up.',
  ),
  LogInSubmissionStatus.googleLogInFailure: const SubmissionStatusMessage(
    title: 'Google login failed!',
    description: 'Try again later.',
  ),
};
