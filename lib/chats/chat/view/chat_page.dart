// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/chat.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

/// The signature of a callback that uses message.
typedef MessageCallback = void Function(Message message);

class MessageSettings extends Equatable {
  const MessageSettings._({
    required this.onReplyTap,
    required this.onEditTap,
    required this.onDeleteTap,
    MessageTapCallback<MessageAction>? onMessageTap,
  }) : _onMessageTap = onMessageTap;

  MessageSettings.create({
    MessageCallback? onEditTap,
    MessageCallback? onReplyTap,
    MessageCallback? onDeleteTap,
    MessageTapCallback<MessageAction>? onMessageTap,
  }) : this._(
          onReplyTap: onReplyTap ?? (_) {},
          onEditTap: onEditTap ?? (_) {},
          onDeleteTap: onDeleteTap ?? (_) {},
          onMessageTap: onMessageTap,
        );

  final MessageCallback onReplyTap;
  final MessageCallback onEditTap;
  final MessageCallback onDeleteTap;
  final MessageTapCallback<MessageAction>? _onMessageTap;

  Future<MessageAction?> onMessageTap(
    TapUpDetails details,
    String messageId, {
    required BuildContext context,
    required bool isMine,
    required bool hasSharedPost,
  }) async {
    if (_onMessageTap != null) {
      return await _onMessageTap?.call(
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

  MessageSettings copyWith({
    MessageCallback? onReplyTap,
    MessageCallback? onEditTap,
    MessageCallback? onDeleteTap,
  }) {
    return MessageSettings._(
      onReplyTap: onReplyTap ?? this.onReplyTap,
      onEditTap: onEditTap ?? this.onEditTap,
      onDeleteTap: onDeleteTap ?? this.onDeleteTap,
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({required this.chatId, required this.chat, super.key});

  final ChatInbox chat;
  final String chatId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        chatId: chatId,
        chatsRepository: context.read<ChatsRepository>(),
      )..add(const ChatMessagesSubscriptionRequested()),
      child: ChatView(chat: chat),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({required this.chat, super.key});

  final ChatInbox chat;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late MessageInputController _messageInputController;
  late FocusNode _focusNode;

  late ItemScrollController _itemScrollController;
  late ItemPositionsListener _itemPositionsListener;
  late ScrollOffsetController _scrollOffsetController;
  late ScrollOffsetListener _scrollOffsetListener;

  Future<void> _reply(Message message) async {
    _messageInputController.setReplyingMessage(message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _edit(Message message) async {
    _messageInputController.setEditingMessage(message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _delete(Message message) {
    context.read<ChatBloc>().add(ChatMessageDeleteRequested(message.id));
  }

  @override
  void initState() {
    super.initState();
    _messageInputController = MessageInputController();
    _focusNode = FocusNode();

    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _scrollOffsetController = ScrollOffsetController();
    _scrollOffsetListener = ScrollOffsetListener.create();
  }

  @override
  void dispose() {
    _messageInputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppBloc>().state.user;
    bool isMine(Message message) {
      return message.sender?.id == user.id;
    }

    return AppScaffold(
      appBar: ChatAppBar(participant: widget.chat.participant),
      releaseFocus: true,
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final messages = state.messages;
                return ChatMessagesListView(
                  messages: messages,
                  messageSettings: MessageSettings.create(
                    onReplyTap: (message) => _reply.call(
                      message.copyWith(
                        replyMessageUsername: isMine(message)
                            ? user.username
                            : widget.chat.participant.username,
                      ),
                    ),
                    onEditTap: _edit,
                    onDeleteTap: _delete,
                  ),
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  scrollOffsetController: _scrollOffsetController,
                  scrollOffsetListener: _scrollOffsetListener,
                );
              },
            ),
          ),
          ChatMessageTextField(
            focusNode: _focusNode,
            itemScrollController: _itemScrollController,
            messageInputController: _messageInputController,
            chat: widget.chat,
          ),
        ],
      ),
    );
  }
}

class ChatMessagesListView extends StatefulWidget {
  const ChatMessagesListView({
    required this.messages,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.scrollOffsetController,
    required this.scrollOffsetListener,
    required this.messageSettings,
    super.key,
  });

  final List<Message> messages;
  final MessageSettings messageSettings;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final ScrollOffsetController scrollOffsetController;
  final ScrollOffsetListener scrollOffsetListener;

  @override
  State<ChatMessagesListView> createState() => _ChatMessagesListViewState();
}

class _ChatMessagesListViewState extends State<ChatMessagesListView> {
  final Map<String, int> _messagesIndex = {};
  final _highlightMessageId = ValueNotifier<String?>(null);
  final _showScrollToBottom = ValueNotifier(false);

  Timer? _highlightTimer;

  MessageSettings get settings => widget.messageSettings;
  List<Message> get messages => widget.messages;

  @override
  void initState() {
    super.initState();
    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ChatMessagesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      _updateMessagesIndex(widget.messages);
    }
  }

  void _updateMessagesIndex(List<Message> messages) {
    for (var index = 0; index < messages.length; index++) {
      _messagesIndex[messages[index].id] = index;
    }
  }

  void _onRepliedMessageTap(String repliedMessageId, List<Message> messages) {
    final index = messages.indexWhere((m) => m.id == repliedMessageId);
    if (index == -1) return;
    widget.itemScrollController.scrollTo(
      index: messages.length - 1 - index,
      duration: 350.ms,
      curve: Curves.easeInOut,
      alignment: 0.2,
    );
    _highlightMessageId.value = repliedMessageId;
    _highlightTimer?.cancel();
    _highlightTimer = Timer(1500.ms, () {
      _highlightMessageId.value = null;
    });
  }

  @override
  void dispose() {
    _highlightMessageId.dispose();
    _showScrollToBottom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ChatBackground(),
        NotificationListener(
          onNotification: (notification) {
            if (notification is UserScrollNotification) {
              if (notification.direction == ScrollDirection.forward) {
                _showScrollToBottom.value = false;
              } else if (notification.direction == ScrollDirection.reverse) {
                _showScrollToBottom.value = true;
              }
            }

            return false;
          },
          child: InViewNotifierCustomScrollView(
            initialInViewIds: [messages.lastOrNull?.id ?? ''],
            isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) {
              return deltaTop < (0.5 * vpHeight) + 80.0 &&
                  deltaBottom > (0.5 * vpHeight) - 80.0;
            },
            slivers: [
              SliverFillRemaining(
                child: ScrollablePositionedList.separated(
                  itemCount: messages.length,
                  reverse: true,
                  itemScrollController: widget.itemScrollController,
                  itemPositionsListener: widget.itemPositionsListener,
                  scrollOffsetController: widget.scrollOffsetController,
                  scrollOffsetListener: widget.scrollOffsetListener,
                  itemBuilder: (context, index) {
                    final isFirst =
                        messages.length - 1 - index == messages.length - 1;
                    final isLast = messages.length - 1 - index <= 0;
                    final isPreviousLast =
                        messages.length - index > messages.length - 1;
                    final message = messages[messages.length - 1 - index];
                    final nextMessage =
                        isLast ? null : messages[messages.length - 2 - index];
                    final previousMessage = isPreviousLast
                        ? null
                        : messages[messages.length - index];
                    final isNextUserSame = nextMessage != null &&
                        message.sender!.id == nextMessage.sender!.id;
                    final isPreviousUserSame = previousMessage != null &&
                        message.sender!.id == previousMessage.sender!.id;

                    bool checkTimeDifference(
                      DateTime date1,
                      DateTime date2,
                    ) =>
                        !Jiffy.parseFromDateTime(date1).isSame(
                          Jiffy.parseFromDateTime(date2),
                          unit: Unit.minute,
                        );

                    var hasTimeDifferenceWithNext = false;
                    if (nextMessage != null) {
                      hasTimeDifferenceWithNext = checkTimeDifference(
                        message.createdAt,
                        nextMessage.createdAt,
                      );
                    }

                    var hasTimeDifferenceWithPrevious = false;
                    if (previousMessage != null) {
                      hasTimeDifferenceWithPrevious = checkTimeDifference(
                        message.createdAt,
                        previousMessage.createdAt,
                      );
                    }

                    final messageWidget = MessageBubble(
                      key: ValueKey(message.id),
                      highlightMessageId: _highlightMessageId,
                      onEditTap: settings.onEditTap,
                      onReplyTap: settings.onReplyTap,
                      onDeleteTap: settings.onDeleteTap,
                      onRepliedMessageTap: (repliedMessageId) =>
                          _onRepliedMessageTap(repliedMessageId, messages),
                      message: message,
                      onMessageTap: (
                        details,
                        messageId, {
                        required isMine,
                        required hasSharedPost,
                      }) =>
                          settings.onMessageTap(
                        details,
                        messageId,
                        context: context,
                        isMine: isMine,
                        hasSharedPost: hasSharedPost,
                      ),
                      borderRadius: ({required isMine}) => BorderRadius.only(
                        topLeft: isMine
                            ? const Radius.circular(22)
                            : (isNextUserSame && !hasTimeDifferenceWithNext)
                                ? const Radius.circular(4)
                                : const Radius.circular(22),
                        topRight: !isMine
                            ? const Radius.circular(22)
                            : (isNextUserSame && !hasTimeDifferenceWithNext)
                                ? const Radius.circular(4)
                                : const Radius.circular(22),
                        bottomLeft: isMine
                            ? const Radius.circular(22)
                            : (isPreviousUserSame &&
                                    !hasTimeDifferenceWithPrevious)
                                ? const Radius.circular(4)
                                : Radius.zero,
                        bottomRight: !isMine
                            ? const Radius.circular(22)
                            : (isPreviousUserSame &&
                                    !hasTimeDifferenceWithPrevious)
                                ? const Radius.circular(4)
                                : Radius.zero,
                      ),
                    );

                    final padding = isFirst
                        ? const EdgeInsets.only(bottom: AppSpacing.md)
                        : isLast
                            ? const EdgeInsets.only(top: AppSpacing.md)
                            : null;

                    return SwipeableMessage(
                      id: message.id,
                      onSwiped: (_) => settings.onReplyTap.call(message),
                      child: Padding(
                        padding: padding ?? EdgeInsets.zero,
                        child: messageWidget,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    final isLast = messages.length - 1 - index == 1;
                    final message = messages[messages.length - 1 - index];
                    final nextMessage =
                        isLast ? null : messages[messages.length - 2 - index];
                    if (message.createdAt.day != nextMessage?.createdAt.day) {
                      return MessageDateTimeSeparator(date: message.createdAt);
                    }
                    final isNextUserSame = nextMessage != null &&
                        message.sender?.id == nextMessage.sender?.id;

                    var hasTimeDifference = false;

                    if (nextMessage != null) {
                      hasTimeDifference =
                          !Jiffy.parseFromDateTime(message.createdAt).isSame(
                        Jiffy.parseFromDateTime(nextMessage.createdAt),
                        unit: Unit.minute,
                      );
                    }

                    if (isNextUserSame && !hasTimeDifference) {
                      return const SizedBox(height: AppSpacing.xxs);
                    }

                    return const SizedBox(height: AppSpacing.sm);
                  },
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _showScrollToBottom,
          child: ScrollToBottomButton(
            scrollToBottom: () {
              widget.itemScrollController.scrollTo(
                index: 0,
                duration: 150.ms,
                curve: Curves.easeIn,
              );
              _showScrollToBottom.value = false;
            },
          ),
          builder: (context, show, child) {
            return Positioned(
              right: 0,
              bottom: 0,
              child: AnimatedScale(
                scale: show ? 1 : 0,
                curve: Curves.bounceInOut,
                duration: 150.ms,
                child: child,
              ),
            );
          },
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: FloatingDateSeparator(
            reverse: true,
            messages: messages,
            itemCount: messages.length,
            itemPositionsListener: widget.itemPositionsListener.itemPositions,
          ),
        ),
      ],
    );
  }
}

class ChatBackground extends StatelessWidget {
  const ChatBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: switch (context.isLight) {
        true =>
          Assets.images.chatBackgroundLightOverlay.image(fit: BoxFit.cover),
        false => ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: AppColors.primaryBackgroundGradient,
                stops: [0, .33, .66, .99],
              ).createShader(bounds);
            },
            child:
                Assets.images.chatBackgroundDarkMask.image(fit: BoxFit.cover),
          ),
      },
    );
  }
}

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    required this.participant,
    super.key,
  });

  final User participant;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      leadingWidth: 36,
      title: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(participant.displayUsername),
        subtitle: Text(context.l10n.onlineText),
        leading: UserStoriesAvatar(
          author: participant,
          enableInactiveBorder: false,
          withAdaptiveBorder: false,
          radius: 26,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(AppSpacing.xxs),
        child: AppDivider(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class ScrollToBottomButton extends StatelessWidget {
  const ScrollToBottomButton({
    required this.scrollToBottom,
    super.key,
  });

  final VoidCallback scrollToBottom;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      shape: const CircleBorder(),
      onPressed: scrollToBottom,
      backgroundColor: context.customReversedAdaptiveColor(
        light: AppColors.white,
        dark: AppColors.emphasizeDarkGrey,
      ),
      child: const Icon(Icons.arrow_downward_rounded),
    );
  }
}
