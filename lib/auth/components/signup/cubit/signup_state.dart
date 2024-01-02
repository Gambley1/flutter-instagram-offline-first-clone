// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'signup_cubit.dart';

/// Message that will be shown to user, when he will try to submit signup form,
/// but there is an error occured. It is used to show user, what exactly went
/// wrong.
typedef SingUpErrorMessage = String;

/// Defines possible signup submission statuses. It is used to manipulate with
/// state, using Bloc, according to state. Therefore, when [success] we
/// can simply navigate user to main page and such.
enum SignupSubmissionStatus {
  /// [SignupSubmissionStatus.idle] indicates that user has not yet submitted
  /// signup form.
  idle,

  /// [SignupSubmissionStatus.inProgress] indicates that user has submitted
  /// signup form and is currently waiting for response from backend.
  inProgress,

  /// [SignupSubmissionStatus.success] indicates that user has successfully
  /// submitted signup form and is currently waiting for response from backend.
  success,

  /// [SignupSubmissionStatus.emailAlreadyRegistered] indicates that email,
  /// provided by user, is occupied by another one in database.
  emailAlreadyRegistered,

  /// [SignupSubmissionStatus.inProgress] indicates that user had no iternet
  /// connection during network request.
  networkError,

  /// [SignupSubmissionStatus.error] indicates something went wrong when user
  /// tried to sign up.
  error,
}

/// Checks current submission status of signup state.
extension SignUpSubmissionStatusX on SignupState {
  /// Checks if current submission status is success.
  bool get isSuccess => submissionStatus == SignupSubmissionStatus.success;

  /// Checks if current submission status is in progress.
  bool get isLoading => submissionStatus == SignupSubmissionStatus.inProgress;

  /// Checks if current submission status is email registered.
  bool get isEmailRegistered =>
      submissionStatus == SignupSubmissionStatus.emailAlreadyRegistered;

  /// Checks if current submission status is network error.
  bool get isNetworkError =>
      submissionStatus == SignupSubmissionStatus.networkError;

  /// Checks if current submission status is error.
  bool get isError =>
      submissionStatus == SignupSubmissionStatus.error ||
      isNetworkError ||
      isEmailRegistered;
}

/// Checks if signup form fields has validation error. If form field invalid
/// returns associated validation `error`, else returns `null`.
extension SignUpFormFieldsValidationError on SignupState {
  /// Defines value of email validation error or null.
  EmailValidationError? get _emailValidationError =>
      email.invalid ? email.error : null;

  /// Defines value of password validation error or null.
  PasswordValidationError? get _passwordValidationError =>
      password.invalid ? password.error : null;

  /// Defines value of fullName validation error or null.
  FullNameValidationError? get _fullNameValidationError =>
      fullName.invalid ? fullName.error : null;

  /// Defines value of username validation error or null.
  UsernameValidationError? get _usernameValidationError =>
      username.invalid ? username.error : null;
}

/// Returns associated with form field `validation error` error m.
extension SignUpFormFieldsTextError on SignupState {
  /// Defines email error text value based on [EmailValidationError].
  String? get emailError => emailValidationErrorMessage[_emailValidationError];

  /// Defines password error text value based on [PasswordValidationError].
  String? get passwordError =>
      passwordValidationErrorMessage[_passwordValidationError];

  /// Defines full name error text value based on [FullNameValidationError].
  String? get fullNameError =>
      fullNameValidationErrorMessage[_fullNameValidationError];

  /// Defines username error text value based on [UsernameValidationError].
  String? get usernameError =>
      usernameValidationErrorMessage[_usernameValidationError];
}

/// {@start template signup_state}
/// Defines signup state. It is used to store all the data, that is needed
/// for signup form to work properly. It also stores signup submission status,
/// that is used to manipulate with state, using Bloc, according to state.
/// {@endtemplatae}
class SignupState extends Equatable {
  const SignupState._({
    required this.fullName,
    required this.email,
    required this.password,
    required this.username,
    required this.userProfileAvatarUrl,
    required this.submissionStatus,
    required this.showPassword,
  });

  /// Creates initial signup state. It is used to define initial state in
  /// [SignupCubit].
  const SignupState.initial()
      : this._(
          fullName: const FullName.unvalidated(),
          email: const Email.unvalidated(),
          password: const Password.unvalidated(),
          username: const Username.unvalidated(),
          userProfileAvatarUrl: '',
          submissionStatus: SignupSubmissionStatus.idle,
          showPassword: false,
        );

  /// Email value state.
  final Email email;

  /// Password value state.
  final Password password;

  /// Stores full fullName valid and value state.
  final FullName fullName;

  /// Stores username valid and value state.
  final Username username;

  /// Signup submission status state.
  final SignupSubmissionStatus submissionStatus;

  /// Stores profile picture value state.
  final String? userProfileAvatarUrl;

  /// Defines if password is visible or not.
  final bool showPassword;

  /// Creates copy of current state with some fields updated.
  SignupState copyWith({
    Email? email,
    Password? password,
    FullName? fullName,
    Username? username,
    String? userProfileAvatarUrl,
    SignupSubmissionStatus? submissionStatus,
    bool? showPassword,
  }) =>
      SignupState._(
        email: email ?? this.email,
        password: password ?? this.password,
        fullName: fullName ?? this.fullName,
        username: username ?? this.username,
        userProfileAvatarUrl: userProfileAvatarUrl ?? this.userProfileAvatarUrl,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        showPassword: showPassword ?? this.showPassword,
      );

  @override
  List<Object?> get props => <Object?>[
        email,
        password,
        fullName,
        username,
        userProfileAvatarUrl,
        submissionStatus,
        showPassword,
      ];
}

final signupSubmissionStatusMessage =
    <SignupSubmissionStatus, SubmissionStatusMessage>{
  SignupSubmissionStatus.emailAlreadyRegistered: const SubmissionStatusMessage(
    title: 'User with this email already exists.',
    description: 'Try another email address.',
  ),
  SignupSubmissionStatus.error: const SubmissionStatusMessage.genericError(),
  SignupSubmissionStatus.networkError:
      const SubmissionStatusMessage.networkError(),
};
