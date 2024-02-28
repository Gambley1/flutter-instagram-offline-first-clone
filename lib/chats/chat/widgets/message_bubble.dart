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

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.onMessageTap,
    this.onEditTap,
    this.onReplyTap,
    this.onDeleteTap,
    this.onRepliedMessageTap,
    this.borderRadius,
    this.shouldHighlight = false,
    super.key,
  });

  final Message message;
  final ValueSetter<Message>? onReplyTap;
  final ValueSetter<Message>? onEditTap;
  final ValueSetter<Message>? onDeleteTap;
  final ValueSetter<String>? onRepliedMessageTap;
  final BorderRadiusGeometry Function({required bool isMine})? borderRadius;
  final MessageTapCallback<MessageAction> onMessageTap;
  final bool shouldHighlight;

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    final user = context.read<AppBloc>().state.user;
    final isMine = message.sender?.id == user.id;
    final messageAlignment = !isMine ? Alignment.topLeft : Alignment.topRight;

    return Tappable(
      animationEffect: TappableAnimationEffect.none,
      onTapUp: (details) async {
        late final onDeleteTap = context.confirmAction(
          title: context.l10n.deleteMessageText,
          content: context.l10n.messageDeleteConfirmationText,
          yesText: context.l10n.deleteText,
          noText: context.l10n.cancelText,
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
      child: AnimatedContainer(
        duration: 350.ms,
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: shouldHighlight ? AppColors.blue.withOpacity(.2) : null,
        ),
        child: FractionallySizedBox(
          alignment: messageAlignment,
          widthFactor: 0.85,
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
                  child: MessageBubbleContent(
                    message: message,
                    onRepliedMessageTap: onRepliedMessageTap,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
