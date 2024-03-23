import 'dart:io';
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/auth/signup/widgets/widgets.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  Uint8List? _imageBytes;
  File? _avatarFile;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
          children: [
            const Gap.v(AppSpacing.xxxlg + AppSpacing.xlg),
            const AppLogo(fit: BoxFit.fitHeight),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    child: AvatarImagePicker(
                      imageBytes: _imageBytes,
                      onUpload: (imageBytes, file) {
                        setState(() {
                          _imageBytes = imageBytes;
                          _avatarFile = file;
                        });
                      },
                    ),
                  ),
                  const Gap.v(AppSpacing.md),
                  const SignUpForm(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xlg,
                    ),
                    child: Align(
                      child: SignUpButton(
                        avatarFile: _avatarFile,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SignInIntoAccountButton(),
          ],
        ),
      ),
    );
  }
}
