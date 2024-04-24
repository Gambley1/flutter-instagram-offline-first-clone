import 'package:app_ui/app_ui.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:shared/shared.dart';

typedef OnMessageTap<T> = Future<T?> Function(
  TapUpDetails details,
  String messageId, {
  required bool isMine,
  required bool hasSharedPost,
});

/// The signature of a callback that uses message.
typedef MessageCallback = void Function(Message message);

class MessageSettings extends Equatable {
  const MessageSettings._({
    required this.onReplyTap,
    required this.onEditTap,
    required this.onDeleteTap,
    OnMessageTap<MessageAction>? onMessageTap,
  }) : _onMessageTap = onMessageTap;

  MessageSettings.create({
    MessageCallback? onEditTap,
    MessageCallback? onReplyTap,
    MessageCallback? onDeleteTap,
    OnMessageTap<MessageAction>? onMessageTap,
  }) : this._(
          onReplyTap: onReplyTap ?? (_) {},
          onEditTap: onEditTap ?? (_) {},
          onDeleteTap: onDeleteTap ?? (_) {},
          onMessageTap: onMessageTap,
        );

  final MessageCallback onReplyTap;
  final MessageCallback onEditTap;
  final MessageCallback onDeleteTap;
  final OnMessageTap<MessageAction>? _onMessageTap;

  Future<MessageAction?> onMessageTap(
    TapUpDetails details,
    String messageId, {
    required BuildContext context,
    required bool isMine,
    required bool hasSharedPost,
  }) async {
    if (_onMessageTap != null) {
      return _onMessageTap.call(
        details,
        messageId,
        isMine: isMine,
        hasSharedPost: hasSharedPost,
      );
    }

    final box = context.findRenderObject()! as RenderBox;
    final localOffset = box.globalToLocal(details.globalPosition);

    return showMenu<MessageAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        localOffset.dx,
        localOffset.dy,
        localOffset.dx,
        localOffset.dy,
      ),
      items: <PopupMenuEntry<MessageAction>>[
        PopupMenuItem(
          value: MessageAction.reply,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.reply_rounded),
            title: Text(context.l10n.replyText),
          ),
        ),
        if (isMine) ...[
          if (!hasSharedPost)
            PopupMenuItem(
              value: MessageAction.edit,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_outlined),
                title: Text(context.l10n.editText),
              ),
            ),
          PopupMenuItem(
            value: MessageAction.delete,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Assets.icons.trash.svg(
                height: AppSize.iconSizeMedium,
                width: AppSize.iconSizeMedium,
                colorFilter: ColorFilter.mode(
                  context.theme.primaryColorLight,
                  BlendMode.srcIn,
                ),
              ),
              title: Text(context.l10n.deleteText),
            ),
          ),
        ],
      ],
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }

  @override
  List<Object?> get props => [onReplyTap, onEditTap, onDeleteTap];
}
