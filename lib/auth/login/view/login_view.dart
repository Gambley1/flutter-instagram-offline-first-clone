import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/login/cubit/login_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/auth/login/widgets/auth_provider_sign_in_button.dart';
import 'package:flutter_instagram_offline_first_clone/auth/login/widgets/login_form.dart';
import 'package:flutter_instagram_offline_first_clone/auth/login/widgets/sign_in_button.dart';
import 'package:flutter_instagram_offline_first_clone/auth/login/widgets/widgets.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xxxlg + AppSpacing.xxxlg),
            const AppLogo(
              height: AppSpacing.xxxlg,
              fit: BoxFit.fitHeight,
              width: double.infinity,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoginForm(),
                  const Padding(
                    padding: EdgeInsets.only(
                      bottom: AppSpacing.md,
                      top: AppSpacing.xs,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ForgotPasswordButton(),
                    ),
                  ),
                  const Align(child: SignInButton()),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: AppDivider(withText: true),
                  ),
                  Align(
                    child: AuthProviderSignInButton(
                      provider: AuthProvider.google,
                      onPressed: () =>
                          context.read<LoginCubit>().loginWithGoogle(),
                    ),
                  ),
                  Align(
                    child: AuthProviderSignInButton(
                      provider: AuthProvider.github,
                      onPressed: () =>
                          context.read<LoginCubit>().loginWithGithub(),
                    ),
                  ),
                ],
              ),
            ),
            const SignUpNewAccountButton(),
          ],
        ),
      ),
    );
  }
}
