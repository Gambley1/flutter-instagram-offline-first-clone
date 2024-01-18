import 'dart:io';
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/signup/components/components.dart';
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
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 84,
                    ),
                    const AppLogo(
                      height: 74,
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                    ),
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
                          const SizedBox(height: 12),
                          const SignupForm(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: SignupButton(
                              avatarFile: _avatarFile,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SigninIntoAccountButton(),
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
