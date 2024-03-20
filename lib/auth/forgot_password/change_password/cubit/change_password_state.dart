part of 'change_password_cubit.dart';

enum ResetPasswordStatus { initial, loading, success, failure, invalidOtp }

/// Extension on [ResetPasswordStatus] that checks current status.
extension SubmissionStatusX on ResetPasswordStatus {
  /// Checks if current submission status is success.
  bool get isSuccess => this == ResetPasswordStatus.success;

  /// Checks if current submission status is in progress.
  bool get isLoading => this == ResetPasswordStatus.loading;

  /// Checks if current submission status is failure.
  bool get isError =>
      this == ResetPasswordStatus.failure ||
      this == ResetPasswordStatus.invalidOtp;

  /// Checks if current submission status is invalid OTP.
  bool get invalidOtp => this == ResetPasswordStatus.invalidOtp;
}

class ChangePasswordState extends Equatable {
  const ChangePasswordState._({
    required this.status,
    required this.password,
    required this.otp,
    required this.showPassword,
  });

  const ChangePasswordState.initial()
      : this._(
          status: ResetPasswordStatus.initial,
          password: const Password.unvalidated(),
          otp: const Otp.unvalidated(),
          showPassword: false,
        );

  final ResetPasswordStatus status;
  final Password password;
  final Otp otp;
  final bool showPassword;

  @override
  List<Object?> get props => [status, password, otp, showPassword];

  ChangePasswordState copyWith({
    ResetPasswordStatus? status,
    Password? password,
    Otp? otp,
    bool? showPassword,
  }) {
    return ChangePasswordState._(
      status: status ?? this.status,
      password: password ?? this.password,
      otp: otp ?? this.otp,
      showPassword: showPassword ?? this.showPassword,
    );
  }
}

final resetPasswordStatusMessage =
    <ResetPasswordStatus, SubmissionStatusMessage>{
  ResetPasswordStatus.failure: const SubmissionStatusMessage.genericError(),
  ResetPasswordStatus.invalidOtp: const SubmissionStatusMessage(
    title: 'Invalid OTP. Please check and re-enter the code.',
  ),
};
