// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'sign_up_cubit.dart';

/// Message that will be shown to user, when he will try to submit signup form,
/// but there is an error occured. It is used to show user, what exactly went
/// wrong.
typedef SingUpErrorMessage = String;

/// Defines possible signup submission statuses. It is used to manipulate with
/// state, using Bloc, according to state. Therefore, when [success] we
/// can simply navigate user to main page and such.
enum SignUpSubmissionStatus {
  /// [SignUpSubmissionStatus.idle] indicates that user has not yet submitted
  /// signup form.
  idle,

  /// [SignUpSubmissionStatus.inProgress] indicates that user has submitted
  /// signup form and is currently waiting for response from backend.
  inProgress,

  /// [SignUpSubmissionStatus.success] indicates that user has successfully
  /// submitted signup form and is currently waiting for response from backend.
  success,

  /// [SignUpSubmissionStatus.emailAlreadyRegistered] indicates that email,
  /// provided by user, is occupied by another one in database.
  emailAlreadyRegistered,

  /// [SignUpSubmissionStatus.inProgress] indicates that user had no iternet
  /// connection during network request.
  networkError,

  /// [SignUpSubmissionStatus.error] indicates something went wrong when user
  /// tried to sign up.
  error,
}

/// Checks current submission status of signup state.
extension SignUpSubmissionStatusX on SignupState {
  /// Checks if current submission status is success.
  bool get isSuccess => submissionStatus == SignUpSubmissionStatus.success;

  /// Checks if current submission status is in progress.
  bool get isLoading => submissionStatus == SignUpSubmissionStatus.inProgress;

  /// Checks if current submission status is email registered.
  bool get isEmailRegistered =>
      submissionStatus == SignUpSubmissionStatus.emailAlreadyRegistered;

  /// Checks if current submission status is network error.
  bool get isNetworkError =>
      submissionStatus == SignUpSubmissionStatus.networkError;

  /// Checks if current submission status is error.
  bool get isError =>
      submissionStatus == SignUpSubmissionStatus.error ||
      isNetworkError ||
      isEmailRegistered;
}

/// {@template signup_state}
/// Defines signup state. It is used to store all the data, that is needed
/// for signup form to work properly. It also stores signup submission status,
/// that is used to manipulate with state, using Bloc, according to state.
/// {@endtemplate}
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
  /// [SignUpCubit].
  const SignupState.initial()
      : this._(
          fullName: const FullName.unvalidated(),
          email: const Email.unvalidated(),
          password: const Password.unvalidated(),
          username: const Username.unvalidated(),
          userProfileAvatarUrl: '',
          submissionStatus: SignUpSubmissionStatus.idle,
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

  /// Sign up submission status state.
  final SignUpSubmissionStatus submissionStatus;

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
    SignUpSubmissionStatus? submissionStatus,
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
    <SignUpSubmissionStatus, SubmissionStatusMessage>{
  SignUpSubmissionStatus.emailAlreadyRegistered: const SubmissionStatusMessage(
    title: 'User with this email already exists.',
    description: 'Try another email address.',
  ),
  SignUpSubmissionStatus.error: const SubmissionStatusMessage.genericError(),
  SignUpSubmissionStatus.networkError:
      const SubmissionStatusMessage.networkError(),
};
