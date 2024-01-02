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
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: const IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 124,
                    ),
                    AppLogo(
                      height: 74,
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LoginForm(),
                          Padding(
                            padding: EdgeInsets.only(bottom: 12, top: 4),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ForgotPasswordButton(),
                            ),
                          ),
                          SigninButton(),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: AppDivider(withText: true),
                          ),
                          AuthProviderSigninButton(
                            provider: AuthProvider.google,
                            // TODO(googlesignin): Implement google sign in
                            onPressed: showCurrentlyUnavailableFeature,
                          ),
                          AuthProviderSigninButton(
                            provider: AuthProvider.facebook,
                            // TODO(facebooksignin): Implement facebook sign in
                            onPressed: showCurrentlyUnavailableFeature,
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
