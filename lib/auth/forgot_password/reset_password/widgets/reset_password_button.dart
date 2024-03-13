import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/forgot_password/forgot_password.dart';
import 'package:flutter_instagram_offline_first_clone/auth/forgot_password/reset_password/reset_password.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';

class ResetPasswordButton extends StatelessWidget {
  const ResetPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      backgroundColor: const MaterialStatePropertyAll(AppColors.blue),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
    final isLoading = context
        .select((ResetPasswordCubit bloc) => bloc.state.status.isLoading);
    final child = switch (isLoading) {
      true => AppButton.inProgress(style: style, scale: 0.5),
      _ => AppButton.auth(
          context.l10n.changePasswordText,
          () => context.read<ResetPasswordCubit>().onSubmit(
                email: context.read<ForgotPasswordCubit>().state.email.value,
              ),
          style: style,
        ),
    };
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: switch (context.screenWidth) {
          > 600 => context.screenWidth * .6,
          _ => context.screenWidth,
        },
      ),
      child: child,
    );
  }
}
