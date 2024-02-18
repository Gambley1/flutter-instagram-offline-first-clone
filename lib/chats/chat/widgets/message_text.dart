import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/parse_attachments.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

/// {@template streamMessageText}
/// The text content of a message.
/// {@endtemplate}
class MessageText extends StatelessWidget {
  /// {@macro message_text}
  const MessageText({
    required this.message,
    required this.isOnlyEmoji,
    required this.isMine,
    super.key,
    this.onMentionTap,
    this.onLinkTap,
  });

  /// Message whose text is to be displayed
  final Message message;

  /// The action to perform when a mention is tapped
  final ValueSetter<User>? onMentionTap;

  /// Whether the text contains only from emojies.
  final bool isOnlyEmoji;

  /// Whether the message send is from the current user.
  final bool isMine;

  /// The action to perform when a link is tapped
  final void Function(String)? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final text = message.message.replaceAll('\n', '\n\n').trim();

    final effectiveTextColor = switch ((isMine, context.isLight)) {
      (true, _) => AppColors.white,
      (false, true) => AppColors.black,
      (false, false) => AppColors.white,
    };

    return MarkdownBody(
      data: text,
      onTapLink: (
        String link,
        String? href,
        String title,
      ) async {
        if (onLinkTap != null) {
          onLinkTap!(link);
        } else {
          await launchURL(context, link);
        }
      },
      styleSheet: MarkdownStyleSheet.fromTheme(context.theme).copyWith(
        a: context.bodyLarge?.copyWith(
          height: 1,
          decoration: TextDecoration.underline,
          color: effectiveTextColor,
          decorationColor: effectiveTextColor,
        ),
        p: context.bodyLarge?.copyWith(
          height: 1,
          fontSize: isOnlyEmoji ? 42 : null,
          color: effectiveTextColor,
        ),
      ),
    );
  }
}
