import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PostCaption extends StatelessWidget {
  const PostCaption({
    required this.username,
    required this.caption,
    required this.onUserProfileAvatarTap,
    super.key,
  });

  final String username;
  final String caption;
  final VoidCallback onUserProfileAvatarTap;

  @override
  Widget build(BuildContext context) {
    if (caption.isEmpty) return const SizedBox.shrink();
    return Text.rich(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      TextSpan(
        children: [
          TextSpan(
            text: '$username ',
            style: context.titleMedium,
            recognizer: TapGestureRecognizer()..onTap = onUserProfileAvatarTap,
          ),
          TextSpan(
            text: caption,
            style: context.bodyMedium,
          ),
        ],
      ),
    );
  }
}
