import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/cubit/auth_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';

/// {@template sign_in_into_account_button}
/// Sign up widget that contains sign up button.
/// {@endtemplate}
class SignInIntoAccountButton extends StatelessWidget {
  /// {@macro sign_in_into_account_button}
  const SignInIntoAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return Tappable(
      onTap: () => cubit.changeAuth(showLogin: true),
      child: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: '${context.l10n.alreadyHaveAccountText} ',
              style: context.bodyMedium,
            ),
            TextSpan(
              text: '${context.l10n.loginText}.',
              style: context.bodyMedium?.apply(color: AppColors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
