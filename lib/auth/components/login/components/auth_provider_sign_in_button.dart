import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/login/cubit/login_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:shared/shared.dart';

class AuthProviderSignInButton extends StatelessWidget {
  const AuthProviderSignInButton({
    required this.provider,
    required this.onPressed,
    super.key,
  });

  final AuthProvider provider;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isInProgress = context.select(
      (LoginCubit cubit) => cubit.state.status.isGoogleAuthInProgress,
    );
    final effectiveIcon = switch (provider) {
      AuthProvider.facebook => Assets.icons.facebook.svg(),
      AuthProvider.google => Assets.icons.google.svg(),
    };
    final showLoading =
        switch ((isInProgress, provider.value == AuthProvider.google.value)) {
      (true, true) => true,
      (true, false) => false,
      (false, false) => false,
      (false, true) => false,
    };
    final icon = SizedBox.square(
      dimension: 24,
      child: effectiveIcon,
    );
    return Container(
      constraints: BoxConstraints(
        minWidth: switch (context.screenWidth) {
          > 600 => context.screenWidth * .6,
          _ => context.screenWidth,
        },
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Tappable(
        throttle: true,
        throttleDuration: 650.ms,
        color: context.theme.focusColor,
        borderRadius: 4,
        onTap: onPressed,
        child: showLoading
            ? Center(child: AppCircularProgress(context.adaptiveColor))
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: icon),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        context.l10n.signInWithText(provider.value),
                        style: context.labelLarge?.copyWith(
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

enum AuthProvider {
  facebook('Facebook'),
  google('Google');

  const AuthProvider(this.value);

  final String value;
}
