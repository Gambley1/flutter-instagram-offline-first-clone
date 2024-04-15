import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/bubble/bubble.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/chat_context.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/message_content.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/message_text.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/text_background.dart';
import 'package:shared/shared.dart';

class ChatMessageFactory {
  const ChatMessageFactory();

  Widget createChatNotificationFromText({
    required BuildContext context,
    required CustomRichText text,
  }) {
    return _Notification(
      text: text.toInlineSpan(context),
    );
  }

  Widget createChatNotificationBubble({required InlineSpan span}) =>
      _Notification(text: span);

  Widget createChatNotification({
    required int id,
    required BuildContext context,
    required Widget body,
  }) {
    return Align(
      key: ValueKey<int>(id),
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.only(top: 3, bottom: 3, left: 6, right: 6),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(60),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: body,
      ),
    );
  }

  Widget create({
    required BuildContext context,
    required bool isOutgoing,
    required Widget body,
    bool withBubble = true,
  }) {
    return _BaseMessage(
      alignment: isOutgoing ? Alignment.topRight : Alignment.topLeft,
      body: withBubble ? _Bubble(isOutgoing: isOutgoing, child: body) : body,
    );
  }

  Widget createCustom({
    required BuildContext context,
    required AlignmentGeometry alignment,
    required Widget body,
  }) {
    return _BaseMessage(
      alignment: alignment,
      body: body,
    );
  }

  Widget createConversationMessage({
    required BuildContext context,
    required Widget? reply,
    required Widget? senderTitle,
    required List<Widget> blocks,
    required bool isOutgoing,
  }) {
    return createFromBlocks(
      context: context,
      isOutgoing: isOutgoing,
      blocks: <Widget>[
        if (senderTitle != null) senderTitle,
        if (reply != null) reply,
        ...blocks,
      ],
    );
  }

  Widget createFromBlocks({
    required BuildContext context,
    required bool isOutgoing,
    required List<Widget> blocks,
    bool withBubble = true,
  }) {
    return _BaseMessage(
      alignment: isOutgoing ? Alignment.topRight : Alignment.topLeft,
      body: withBubble
          ? _Bubble(
              isOutgoing: isOutgoing,
              child: MessageContent(children: blocks),
            )
          : MessageContent(children: blocks),
    );
  }
}

class _BaseMessage extends StatelessWidget {
  const _BaseMessage({
    required this.alignment,
    required this.body,
  });

  final AlignmentGeometry alignment;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final chatContext = ChatContext.of(context);
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: chatContext.maxWidth),
        child: body,
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.isOutgoing,
    required this.child,
  });

  final bool isOutgoing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Bubble(
      borderColor: isOutgoing ? AppColors.white : AppColors.brightGrey,
      radius: 10,
      child: ColoredBox(
        color: isOutgoing ? AppColors.black : AppColors.red,
        child: child,
      ),
    );
  }
}

class _Notification extends StatelessWidget {
  const _Notification({required this.text});

  final InlineSpan text;

  @override
  Widget build(BuildContext context) {
    return TextBackground(
      margin: 8,
      backgroundColor: Colors.black26,
      child: Text.rich(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
