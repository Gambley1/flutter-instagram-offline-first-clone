import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/login/cubit/login_cubit.dart';

class SigninButton extends StatelessWidget {
  const SigninButton({super.key});

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
    final isLoading =
        context.select<LoginCubit, bool>((b) => b.state.status.isLoading);
    if (isLoading) {
      return AppButton.inProgress(
        style: style,
        scale: 0.5,
      );
    }
    return AppButton.auth(
      'Login',
      () => context.read<LoginCubit>().onSubmit(),
      style: style,
      outlined: true,
    );
  }
}
