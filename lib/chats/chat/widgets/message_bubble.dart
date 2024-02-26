import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/chat.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:shared/shared.dart';

typedef MessageTapCallback<T> = Future<T?> Function(
  TapUpDetails details,
  String messageId, {
  required bool isMine,
  required bool hasSharedPost,
});

typedef MessageBuilder = Widget Function(
  BuildContext,
  Message message,
  List<Message>,
  MessageBubble defaultMessageWidget, {
  EdgeInsets? padding,
});

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.onMessageTap,
    this.onEditTap,
    this.onReplyTap,
    this.onDeleteTap,
    this.borderRadius,
    super.key,
  });

  final ValueSetter<Message>? onReplyTap;
  final ValueSetter<Message>? onEditTap;
  final ValueSetter<Message>? onDeleteTap;
  final Message message;
  final BorderRadiusGeometry Function({required bool isMine})? borderRadius;
  final MessageTapCallback<MessageAction> onMessageTap;

  MessageBubble copyWith({
    ValueSetter<Message>? onReplyTap,
    ValueSetter<Message>? onEditTap,
    ValueSetter<Message>? onDeleteTap,
    Message? message,
    BorderRadiusGeometry Function({required bool isMine})? borderRadius,
    MessageTapCallback<MessageAction>? onMessageTap,
  }) =>
      MessageBubble(
        message: message ?? this.message,
        onMessageTap: onMessageTap ?? this.onMessageTap,
        onReplyTap: onReplyTap ?? this.onReplyTap,
        onEditTap: onEditTap ?? this.onEditTap,
        onDeleteTap: onDeleteTap ?? this.onDeleteTap,
        borderRadius: borderRadius ?? this.borderRadius,
      );

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = message.sender?.id == user.id;
    final messageAlignment = !isMine ? Alignment.topLeft : Alignment.topRight;

    return Tappable(
      animationEffect: TappableAnimationEffect.none,
      onTapUp: (details) async {
        late final onDeleteTap = context.confirmAction(
          title: 'Delete message',
          content: 'Are you sure you want to delete this message?',
          yesText: context.l10n.delete,
          fn: () => this.onDeleteTap?.call(message),
        );
        final option = await onMessageTap.call(
          details,
          message.id,
          isMine: isMine,
          hasSharedPost: message.sharedPost != null,
        );
        if (option == null) return;
        void action() => switch (option) {
              MessageAction.delete => onDeleteTap,
              MessageAction.edit => onEditTap?.call(message),
              MessageAction.reply => onReplyTap?.call(message),
            };
        action();
      },
      child: FractionallySizedBox(
        alignment: messageAlignment,
        widthFactor: 0.9,
        child: Align(
          alignment: messageAlignment,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius?.call(isMine: isMine) ??
                      const BorderRadius.all(Radius.circular(22)),
                ),
              ),
              child: RepaintBoundary(
                child: MessageBubbleContent(message: message),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
