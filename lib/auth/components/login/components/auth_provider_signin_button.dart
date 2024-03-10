import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';

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
    final effectiveIcon = switch (provider) {
      AuthProvider.facebook => Assets.icons.facebook.svg(),
      AuthProvider.google => Assets.icons.google.svg(),
    };
    final icon = SizedBox.square(
      dimension: 24,
      child: effectiveIcon,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: switch (context.screenWidth) {
          > 600 => context.screenWidth * .6,
          _ => context.screenWidth,
        },
      ),
      child: AppButton(
        icon: icon,
        text: context.l10n.signInWithText(provider.value),
        textStyle:
            context.labelLarge?.copyWith(overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(shape: LinearBorder.none),
        onPressed: onPressed,
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
