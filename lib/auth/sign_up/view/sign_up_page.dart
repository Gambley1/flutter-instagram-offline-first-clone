import 'dart:io';
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/sign_up/cubit/sign_up_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/auth/sign_up/widgets/widgets.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:user_repository/user_repository.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(
        userRepository: context.read<UserRepository>(),
        notificationsRepository: context.read<NotificationsRepository>(),
      ),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
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
