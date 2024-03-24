part of 'change_password_cubit.dart';

enum ChangePasswordStatus {
  initial,
  loading,
  success,
  failure,
  invalidOtp;

  bool get isSuccess => this == ChangePasswordStatus.success;
  bool get isLoading => this == ChangePasswordStatus.loading;
  bool get isError => this == ChangePasswordStatus.failure || isInvalidOtp;
  bool get isInvalidOtp => this == ChangePasswordStatus.invalidOtp;
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
          status: ChangePasswordStatus.initial,
          password: const Password.pure(),
          otp: const Otp.pure(),
          showPassword: false,
        );

  final ChangePasswordStatus status;
  final Password password;
  final Otp otp;
  final bool showPassword;

  @override
  List<Object?> get props => [status, password, otp, showPassword];

  ChangePasswordState copyWith({
    ChangePasswordStatus? status,
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

final changePasswordStatusMessage =
    <ChangePasswordStatus, SubmissionStatusMessage>{
  ChangePasswordStatus.failure: const SubmissionStatusMessage.genericError(),
  ChangePasswordStatus.invalidOtp: const SubmissionStatusMessage(
    title: 'Invalid OTP. Please check and re-enter the code.',
  ),
};
