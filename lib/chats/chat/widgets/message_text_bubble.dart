import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/widgets.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class MessageTextBubble extends StatelessWidget {
  /// {@macro textBubble}
  const MessageTextBubble({
    required this.message,
    required this.isOnlyEmoji,
    required this.isMine,
    super.key,
    this.textBuilder,
    this.onLinkTap,
    this.onMentionTap,
  });

  final Message message;

  final bool isOnlyEmoji;

  final bool isMine;

  final Widget Function(BuildContext context, Message message)? textBuilder;

  final void Function(String url)? onLinkTap;

  final void Function(User user)? onMentionTap;

  @override
  Widget build(BuildContext context) {
    if (message.message.trim().isEmpty) return const SizedBox.shrink();
    return textBuilder != null
        ? textBuilder!(context, message)
        : MessageText(
            onLinkTap: onLinkTap,
            message: message,
            isOnlyEmoji: isOnlyEmoji,
            isMine: isMine,
            onMentionTap: onMentionTap,
          );
  }
}
