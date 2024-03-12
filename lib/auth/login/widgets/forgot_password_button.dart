import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/auth/forgot_password/view/forgot_password_page.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:shared/shared.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      throttle: true,
      throttleDuration: 650.ms,
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          ManageForgotPasswordPage.route(),
          (_) => true,
        );
      },
      child: Text(
        context.l10n.forgotPasswordText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.titleSmall?.copyWith(color: AppColors.blue),
      ),
    );
  }
}
