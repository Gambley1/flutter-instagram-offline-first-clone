import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/auth/sign_up/cubit/sign_up_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/auth/sign_up/widgets/widgets.dart';
import 'package:shared/shared.dart';

/// {@template sign_up_form}
/// Sign up form that contains email and password fields.
/// {@endtemplate}
class SignUpForm extends StatefulWidget {
  /// {@macro sign_up_form}
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignupState>(
      listener: (context, state) {
        if (state.submissionStatus.isError) {
          openSnackbar(
            SnackbarMessage.error(
              title:
                  signupSubmissionStatusMessage[state.submissionStatus]!.title,
              description: signupSubmissionStatusMessage[state.submissionStatus]
                  ?.description,
            ),
            clearIfQueue: true,
          );
        }
      },
      listenWhen: (p, c) => p.submissionStatus != c.submissionStatus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EmailTextField(),
          const FullNameTextField(),
          const UsernameTextField(),
          const PasswordTextField(),
        ].spacerBetween(height: AppSpacing.md),
      ),
    );
  }
}
