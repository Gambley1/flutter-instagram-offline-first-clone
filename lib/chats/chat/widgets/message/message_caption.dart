import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/chat_context.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/message_text.dart';
import 'package:shared/shared.dart' as s;

class MessageCaption extends StatelessWidget {
  const MessageCaption({
    required this.text,
    required this.shortInfo,
    super.key,
    this.padding,
  });

  final s.CustomRichText text;
  final Widget shortInfo;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final chatContextData = ChatContext.of(context);
    return Padding(
      padding: padding ??
          EdgeInsets.only(
            left: chatContextData.horizontalPadding,
            right: chatContextData.horizontalPadding,
          ),
      child: MessageText(
        text: text,
        shortInfo: shortInfo,
      ),
    );
  }
}
