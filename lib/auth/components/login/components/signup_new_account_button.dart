import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/cubit/auth_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';

/// {@template signup_widget}
/// Signup widget that contains signup button.
/// {@endtemplate}
class SignupNewAccountButton extends StatelessWidget {
  /// {@macro signup_widget}
  const SignupNewAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return Tappable(
      onTap: () => cubit.changeAuth(showLogin: false),
      child: Text.rich(
        overflow: TextOverflow.ellipsis,
        style: context.bodyMedium,
        TextSpan(
          children: [
            TextSpan(text: '${context.l10n.noAccount}? '),
            TextSpan(
              text: '${context.l10n.signUp}.',
              style: context.bodyMedium?.copyWith(color: AppColors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
