import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/chat.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

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
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _messageInputController = MessageInputController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
  }

  Future<MessageAction?> onMessageTap(
    TapUpDetails details,
    String messageId, {
    required bool isMine,
    required bool hasSharedPost,
  }) async {
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
        const PopupMenuItem(
          value: MessageAction.reply,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.reply_rounded),
            title: Text('Reply'),
          ),
        ),
        if (isMine) ...[
          if (!hasSharedPost)
            const PopupMenuItem(
              value: MessageAction.edit,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
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
              title: const Text('Delete'),
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

  @override
  void dispose() {
    _messageInputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.select((ChatBloc bloc) => bloc.state.messages);
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return AppScaffold(
      appBar: ChatAppBar(participant: widget.chat.participant),
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: ChatMessagesListView(
              scrollController: _scrollController,
              messages: messages,
              onMessageTap: onMessageTap,
              messageBuilder:
                  (context, message, messages, defaultMessageWidget) {
                final isMine = message.sender?.id == user.id;

                void reply(Message message) => _reply.call(
                      message.copyWith(
                        replyMessageUsername: isMine
                            ? user.username
                            : widget.chat.participant.username,
                      ),
                    );

                return SwipeableMessage(
                  id: message.id,
                  onSwiped: (_) => reply(message),
                  child: defaultMessageWidget.copyWith(
                    onReplyTap: reply,
                    onEditTap: _edit,
                    onDeleteTap: (message) => context
                        .read<ChatBloc>()
                        .add(ChatMessageDeleteRequested(message.id)),
                  ),
                );
              },
            ),
          ),
          ChatMessageTextField(
            focusNode: _focusNode,
            scrollController: _scrollController,
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
    required this.onMessageTap,
    required this.scrollController,
    this.messageBuilder,
    super.key,
  });

  final List<Message> messages;
  final MessageTapCallback<MessageAction> onMessageTap;
  final MessageBuilder? messageBuilder;
  final ScrollController scrollController;

  @override
  State<ChatMessagesListView> createState() => _ChatMessagesListViewState();
}

class _ChatMessagesListViewState extends State<ChatMessagesListView> {
  final Map<String, int> _messagesIndex = {};
  final _showScrollToBottom = ValueNotifier(false);
  final _itemPositionListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ChatMessagesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      updateMessagesIndex(widget.messages);
    }
  }

  void updateMessagesIndex(List<Message> messages) {
    for (var index = 0; index < messages.length; index++) {
      _messagesIndex[messages[index].id] = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;

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
          child: ScrollablePositionedList.separated(
            itemCount: messages.length,
            reverse: true,
            itemPositionsListener: _itemPositionListener,
            itemBuilder: (context, index) {
              final isLast = messages.length - 1 - index <= 0;
              final isPreviosLast =
                  messages.length - index > messages.length - 1;
              final message = messages[messages.length - 1 - index];
              final nextMessage =
                  isLast ? null : messages[messages.length - 2 - index];
              final previosMessage =
                  isPreviosLast ? null : messages[messages.length - index];
              final isNextUserSame = nextMessage != null &&
                  message.sender!.id == nextMessage.sender!.id;
              final isPreviusUserSame = previosMessage != null &&
                  message.sender!.id == previosMessage.sender!.id;

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
              if (previosMessage != null) {
                hasTimeDifferenceWithPrevious = checkTimeDifference(
                  message.createdAt,
                  previosMessage.createdAt,
                );
              }

              Widget messageWidget = MessageBubble(
                key: ValueKey(message.id),
                message: message,
                onMessageTap: widget.onMessageTap,
                borderRadius: (isMine) => BorderRadius.only(
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
                      : (isPreviusUserSame && !hasTimeDifferenceWithPrevious)
                          ? const Radius.circular(4)
                          : Radius.zero,
                  bottomRight: !isMine
                      ? const Radius.circular(22)
                      : (isPreviusUserSame && !hasTimeDifferenceWithPrevious)
                          ? const Radius.circular(4)
                          : Radius.zero,
                ),
              );

              if (widget.messageBuilder != null) {
                messageWidget = widget.messageBuilder!.call(
                  context,
                  message,
                  messages,
                  messageWidget as MessageBubble,
                );
              }
              return messageWidget;
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
        ValueListenableBuilder<bool>(
          valueListenable: _showScrollToBottom,
          child: ScrollToBottomButton(
            scrollToBottom: () {
              widget.scrollController.animateTo(
                0,
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
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: [
              ui.Color.fromARGB(255, 119, 69, 121),
              ui.Color.fromARGB(255, 141, 124, 189),
              ui.Color.fromARGB(255, 50, 94, 170),
              ui.Color.fromARGB(255, 111, 156, 189),
            ],
            stops: [0, .33, .66, .99],
          ).createShader(bounds);
        },
        child: Assets.images.chatBackground2.image(
          fit: BoxFit.cover,
        ),
      ),
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
      leadingWidth: 24,
      title: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(participant.username ?? participant.fullName ?? ''),
        subtitle: const Text('online'),
        leading: UserStoriesAvatar(
          author: participant,
          enableUnactiveBorder: false,
          withAdaptiveBorder: false,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(2),
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
        light: const ui.Color.fromARGB(255, 105, 111, 123),
        dark: const ui.Color(0xff1c1e22),
      ),
      child: const Icon(
        Icons.arrow_downward_rounded,
        color: Colors.white,
      ),
    );
  }
}
