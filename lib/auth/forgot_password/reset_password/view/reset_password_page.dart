import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/cubit/forgot_password_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/auth/forgot_password/reset_password/reset_password.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:shared/shared.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  void _confirmGoBack(BuildContext context) => context.confirmAction(
        fn: () => context
            .read<ManagePasswordCubit>()
            .changeScreen(showForgotPassword: true),
        title: context.l10n.goBackConfirmationText,
        content: context.l10n.loseAllEditsText,
        noText: context.l10n.cancelText,
        yesText: context.l10n.goBackText,
        yesTextStyle: context.labelLarge?.apply(color: AppColors.blue),
      );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      onPopInvoked: (didPop) {
        if (didPop) return;
        _confirmGoBack(context);
      },
      appBar: AppBar(
        title: Text(context.l10n.changePasswordText),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.adaptive.arrow_back),
          onPressed: () => _confirmGoBack(context),
        ),
      ),
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxlg * 3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const ResetPasswordForm(),
                  const Align(child: ResetPasswordButton()),
                ].insertBetween(const SizedBox(height: AppSpacing.md)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
