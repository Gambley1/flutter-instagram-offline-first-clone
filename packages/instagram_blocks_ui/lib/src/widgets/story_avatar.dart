import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    required this.avatarUrl,
    required this.isMine,
    required this.username,
    required this.hasStories,
    required this.onTap,
    required this.onLongPress,
    required this.mineStoryLabel,
    super.key,
  });

  final String avatarUrl;
  final bool isMine;
  final String mineStoryLabel;
  final String username;
  final bool hasStories;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = context.titleSmall!;
    final style = isMine
        ? defaultTextStyle
        : hasStories
            ? defaultTextStyle
            : defaultTextStyle.copyWith(color: Colors.grey.shade500);

    return Column(
      children: [
        UserProfileAvatar(
          hasStories: hasStories,
          hasUnseenStories: hasStories,
          withAddButton: isMine,
          onTap: (_) => onTap,
          onLongPress: onLongPress,
          enableUnactiveBorder: !isMine,
          avatarUrl: avatarUrl,
          scaleStrength: ScaleStrength.xxs,
        ),
        const SizedBox(height: 6),
        DefaultTextStyle(
          style: style,
          child: Text(
            isMine ? mineStoryLabel : username,
          ),
        ),
      ],
    );
  }
}
