import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/auth/forgot_password/forgot_password.dart';
import 'package:flutter_instagram_offline_first_clone/auth/forgot_password/widgets/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';

class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          openSnackbar(
            SnackbarMessage.success(
              title: context.l10n.verificationTokenSentText(state.email.value),
            ),
          );
        }
        if (state.status.isError) {
          openSnackbar(
            SnackbarMessage.error(
              title: forgotPasswordStatusMessage[state.status]!.title,
              description:
                  forgotPasswordStatusMessage[state.status]?.description,
            ),
            clearIfQueue: true,
          );
        }
      },
      listenWhen: (p, c) => p.status != c.status,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ForgotPasswordEmailField(),
        ],
      ),
    );
  }
}
