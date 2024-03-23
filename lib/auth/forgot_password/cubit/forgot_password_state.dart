// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'forgot_password_cubit.dart';

enum ForgotPasswordStatus {
  initial,
  loading,
  success,
  failure,
  tooManyRequests;

  bool get isSuccess => this == ForgotPasswordStatus.success;
  bool get isLoading => this == ForgotPasswordStatus.loading;
  bool get isError => this == ForgotPasswordStatus.failure || isTooManyRequests;
  bool get isTooManyRequests => this == ForgotPasswordStatus.tooManyRequests;
}

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState._({required this.status, required this.email});

  const ForgotPasswordState.initial()
      : this._(
          status: ForgotPasswordStatus.initial,
          email: const Email.pure(),
        );

  final ForgotPasswordStatus status;
  final Email email;

  @override
  List<Object?> get props => [status, email];

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    Email? email,
  }) {
    return ForgotPasswordState._(
      status: status ?? this.status,
      email: email ?? this.email,
    );
  }
}

final forgotPasswordStatusMessage =
    <ForgotPasswordStatus, SubmissionStatusMessage>{
  ForgotPasswordStatus.failure: const SubmissionStatusMessage.genericError(),
  ForgotPasswordStatus.tooManyRequests: const SubmissionStatusMessage(
    title: 'Too many requests.',
    description: 'Please try again later.',
  ),
};
