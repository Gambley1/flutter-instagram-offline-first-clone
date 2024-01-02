import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/cubit/auth_cubit.dart';

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
      child: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Don't have an account?",
              style: context.bodyMedium,
            ),
            WidgetSpan(
              child: SizedBox(
                width: context.textSpacing,
              ),
            ),
            TextSpan(
              text: 'Sign up.',
              style: context.bodyMedium?.copyWith(
                color: Colors.blue.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
