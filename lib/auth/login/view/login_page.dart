import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/login/cubit/login_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/auth/login/widgets/auth_provider_sign_in_button.dart';
import 'package:flutter_instagram_offline_first_clone/auth/login/widgets/login_form.dart';
import 'package:flutter_instagram_offline_first_clone/auth/login/widgets/sign_in_button.dart';
import 'package:flutter_instagram_offline_first_clone/auth/login/widgets/widgets.dart';
import 'package:user_repository/user_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginCubit(userRepository: context.read<UserRepository>()),
      child: const LoginView(),
    );
  }
}

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
            const Gap.v(AppSpacing.xxxlg + AppSpacing.xxxlg),
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
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: AppDivider(
                          endIndent: AppSpacing.sm,
                          indent: AppSpacing.md,
                          color: AppColors.white,
                          height: 36,
                        ),
                      ),
                      Text(
                        'OR',
                        style: context.titleMedium,
                      ),
                      const Expanded(
                        child: AppDivider(
                          color: AppColors.white,
                          indent: AppSpacing.sm,
                          endIndent: AppSpacing.md,
                          height: 36,
                        ),
                      ),
                    ],
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
