import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/widgets.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class TextBubble extends StatelessWidget {
  /// {@macro textBubble}
  const TextBubble({
    required this.message,
    required this.isOnlyEmoji,
    super.key,
    this.textBuilder,
    this.onLinkTap,
    this.onMentionTap,
  });

  final Message message;

  final bool isOnlyEmoji;

  final Widget Function(BuildContext, Message)? textBuilder;

  final void Function(String)? onLinkTap;

  final void Function(User)? onMentionTap;

  @override
  Widget build(BuildContext context) {
    if (message.message.trim().isEmpty) return const SizedBox.shrink();
    return textBuilder != null
        ? textBuilder!(context, message)
        : MessageText(
            onLinkTap: onLinkTap,
            message: message,
            isOnlyEmoji: isOnlyEmoji,
            onMentionTap: onMentionTap,
          );
  }
}
