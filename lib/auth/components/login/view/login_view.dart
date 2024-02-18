import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/app/view/view.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/login/components/auth_provider_signin_button.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/login/components/components.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/login/components/login_form.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/login/components/signin_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: const IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: AppSpacing.xxxlg + AppSpacing.xxxlg),
                    AppLogo(
                      height: AppSpacing.xxxlg,
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LoginForm(),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: AppSpacing.md,
                              top: AppSpacing.xs,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ForgotPasswordButton(),
                            ),
                          ),
                          Align(child: SignInButton()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: AppDivider(withText: true),
                          ),
                          Align(
                            child: AuthProviderSignInButton(
                              provider: AuthProvider.google,
                              // TODO(googlesignin): Implement google sign in
                              onPressed: showCurrentlyUnavailableFeature,
                            ),
                          ),
                          Align(
                            child: AuthProviderSignInButton(
                              provider: AuthProvider.facebook,
                              // TODO(facebooksignin): Implement facebook login
                              onPressed: showCurrentlyUnavailableFeature,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SignupNewAccountButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
