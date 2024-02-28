import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/app/view/view.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      // TODO(forgotpassword): Implement forgot password feature
      onTap: showCurrentlyUnavailableFeature,
      child: Text(
        context.l10n.forgotPasswordText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.titleSmall?.copyWith(color: AppColors.blue),
      ),
    );
  }
}
