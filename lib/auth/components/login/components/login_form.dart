import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/login/components/components.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/login/cubit/login_cubit.dart';

/// {@template login_form}
/// Login form that contains email and password fields.
/// {@endtemplate}
class LoginForm extends StatefulWidget {
  /// {@macro login_form}
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  void initState() {
    super.initState();
    context.read<LoginCubit>().resetState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<LoginCubit>().resetState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isError) {
          openSnackbar(
            SnackbarMessage.error(
              title: loginSubmissionStatusMessage[state.status]!.title,
              description:
                  loginSubmissionStatusMessage[state.status]?.description ??
                      state.message,
            ),
            clearIfQueue: true,
          );
        }
      },
      listenWhen: (p, c) => p.status != c.status,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmailTextField(),
          SizedBox(height: AppSpacing.md),
          PasswordTextField(),
        ],
      ),
    );
  }
}
