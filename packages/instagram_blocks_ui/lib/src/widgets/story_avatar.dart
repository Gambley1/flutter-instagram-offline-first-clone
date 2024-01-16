// ignore_for_file: avoid_positional_boolean_parameters

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/post_large/post_header.dart';
import 'package:user_repository/user_repository.dart';

typedef StoryAvatarBuilder = Widget Function(
  BuildContext context,
  User author,
  OnAvatarTapCallback onAvatarTap,
  bool isMine,
  VoidCallback? onLongPress,
);

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    required this.author,
    required this.isMine,
    required this.username,
    required this.onTap,
    required this.myStoryLabel,
    this.onLongPress,
    super.key,
    this.avatarBuilder,
  });

  final User author;
  final bool isMine;
  final String myStoryLabel;
  final String username;
  final OnAvatarTapCallback onTap;
  final VoidCallback? onLongPress;
  final StoryAvatarBuilder? avatarBuilder;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = context.titleSmall!;
    final style = defaultTextStyle;
    // final style = isMine
    // ? defaultTextStyle
    // : hasStories
    // ? defaultTextStyle
    // : defaultTextStyle.copyWith(color: Colors.grey.shade500);

    return Column(
      children: [
        avatarBuilder?.call(
              context,
              author,
              onTap,
              isMine,
              onLongPress,
            ) ??
            UserProfileAvatar(
              withAddButton: isMine,
              onTap: (_) => onTap,
              onLongPress: onLongPress,
              enableUnactiveBorder: !isMine,
              avatarUrl: author.avatarUrl,
              scaleStrength: ScaleStrength.xxs,
            ),
        const SizedBox(height: 6),
        DefaultTextStyle(
          style: style,
          child: Text(
            isMine ? myStoryLabel : username,
          ),
        ),
      ],
    );
  }
}
