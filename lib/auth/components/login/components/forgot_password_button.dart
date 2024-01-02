import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/app/view/view.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      // TODO(forgotpassword): Implement forgot password feature
      onTap: showCurrentlyUnavailableFeature,
      child: Text(
        'Forgot password?',
        style:
            context.titleSmall?.copyWith(color: Colors.blue.shade500),
      ),
    );
  }
}
