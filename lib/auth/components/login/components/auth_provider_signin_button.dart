import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class AuthProviderSigninButton extends StatelessWidget {
  const AuthProviderSigninButton({
    required this.provider,
    required this.onPressed,
    super.key,
  });

  final AuthProvider provider;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      icon: const Icon(Icons.wordpress_outlined),
      text: 'Sign in with ${provider.value}',
      style: ElevatedButton.styleFrom(
        shape: LinearBorder.none,
      ),
      onPressed: onPressed,
    );
  }
}

enum AuthProvider {
  facebook('Facebook'),
  google('Google');

  const AuthProvider(this.value);

  final String value;
}
