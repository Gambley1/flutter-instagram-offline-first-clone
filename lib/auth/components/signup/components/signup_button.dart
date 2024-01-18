import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/signup/cubit/signup_cubit.dart';

class SignupButton extends StatelessWidget {
  const SignupButton({
    super.key,
    this.avatarFile,
  });

  final File? avatarFile;

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
        context.select<SignupCubit, bool>((c) => c.state.isLoading);
    if (isLoading) {
      return AppButton.inProgress(
        style: style,
        scale: 0.5,
      );
    }
    return AppButton.auth(
      'Sign up',
      () => context.read<SignupCubit>().onSubmit(avatarFile: avatarFile),
      style: style,
      outlined: true,
    );
  }
}
