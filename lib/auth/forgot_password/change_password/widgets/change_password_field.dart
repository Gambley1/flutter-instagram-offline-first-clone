import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/forgot_password/change_password/change_password.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:shared/shared.dart';

class ResetPasswordField extends StatefulWidget {
  const ResetPasswordField({super.key});

  @override
  State<ResetPasswordField> createState() => _ResetPasswordFieldState();
}

class _ResetPasswordFieldState extends State<ResetPasswordField> {
  late Debouncer _debouncer;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer();
    final cubit = context.read<ChangePasswordCubit>()..resetState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        cubit.onPasswordUnfocused();
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordError = context.select(
      (ChangePasswordCubit cubit) => cubit.state.password.errorMessage,
    );
    final showPassword = context.select(
      (ChangePasswordCubit cubit) => cubit.state.showPassword,
    );
    final isLoading = context.select(
      (ChangePasswordCubit cubit) => cubit.state.status.isLoading,
    );

    return AppTextField(
      filled: true,
      focusNode: _focusNode,
      hintText: context.l10n.newPasswordText,
      enabled: !isLoading,
      obscureText: !showPassword,
      textInputAction: TextInputAction.done,
      textInputType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.password],
      onChanged: (v) => _debouncer.run(
        () => context.read<ChangePasswordCubit>().onPasswordChanged(v),
      ),
      errorText: passwordError,
      suffixIcon: Tappable(
        color: AppColors.transparent,
        onTap: context.read<ChangePasswordCubit>().changePasswordVisibility,
        child: Icon(
          !showPassword ? Icons.visibility : Icons.visibility_off,
          color: context.customAdaptiveColor(light: AppColors.grey),
        ),
      ),
    );
  }
}
