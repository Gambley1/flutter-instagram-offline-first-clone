import 'package:app_ui/app_ui.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/chat.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
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
  late FocusNode _focusNode;

  late ItemScrollController _itemScrollController;
  late ItemPositionsListener _itemPositionsListener;
  late ScrollOffsetController _scrollOffsetController;
  late ScrollOffsetListener _scrollOffsetListener;

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
        PopupMenuItem(
          value: MessageAction.reply,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.reply_rounded),
            title: Text(context.l10n.reply),
          ),
        ),
        if (isMine) ...[
          if (!hasSharedPost)
            PopupMenuItem(
              value: MessageAction.edit,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_outlined),
                title: Text(context.l10n.edit),
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
              title: Text(context.l10n.delete),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    logI('Build');

    return LayoutBuilder(
      builder: (context, constraints) {
        return AppScaffold(
          appBar: ChatAppBar(participant: widget.chat.participant),
          releaseFocus: true,
          // resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    final messages = state.messages;
                    return ChatMessagesListView(
                      messages: messages,
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      scrollOffsetController: _scrollOffsetController,
                      scrollOffsetListener: _scrollOffsetListener,
                      onMessageTap: onMessageTap,
                      messageBuilder: (
                        context,
                        message,
                        messages,
                        defaultMessageWidget, {
                        padding,
                      }) {
                        final isMine = message.sender?.id == user.id;

                        void reply(Message message) => _reply.call(
                              message.copyWith(
                                replyMessageUsername: isMine
                                    ? user.username
                                    : widget.chat.participant.username,
                              ),
                            );

                        final child = defaultMessageWidget.copyWith(
                          onReplyTap: reply,
                          onEditTap: _edit,
                          onDeleteTap: (message) => context
                              .read<ChatBloc>()
                              .add(ChatMessageDeleteRequested(message.id)),
                        );

                        return SwipeableMessage(
                          id: message.id,
                          onSwiped: (_) => reply(message),
                          child: Padding(
                            padding: padding ?? EdgeInsets.zero,
                            child: child,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Builder(
                builder: (context) {
                  return ChatMessageTextField(
                    focusNode: _focusNode,
                    itemScrollController: _itemScrollController,
                    messageInputController: _messageInputController,
                    chat: widget.chat,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChatMessagesListView extends StatefulWidget {
  const ChatMessagesListView({
    required this.messages,
    required this.onMessageTap,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.scrollOffsetController,
    required this.scrollOffsetListener,
    this.messageBuilder,
    super.key,
  });

  final List<Message> messages;
  final MessageTapCallback<MessageAction> onMessageTap;
  final MessageBuilder? messageBuilder;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final ScrollOffsetController scrollOffsetController;
  final ScrollOffsetListener scrollOffsetListener;

  @override
  State<ChatMessagesListView> createState() => _ChatMessagesListViewState();
}

class _ChatMessagesListViewState extends State<ChatMessagesListView> {
  final Map<String, int> _messagesIndex = {};
  final _showScrollToBottom = ValueNotifier(false);

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
            itemScrollController: widget.itemScrollController,
            itemPositionsListener: widget.itemPositionsListener,
            scrollOffsetController: widget.scrollOffsetController,
            scrollOffsetListener: widget.scrollOffsetListener,
            itemBuilder: (context, index) {
              final isFirst =
                  messages.length - 1 - index == messages.length - 1;
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
                  padding: isFirst
                      ? const EdgeInsets.only(bottom: AppSpacing.md)
                      : isLast
                          ? const EdgeInsets.only(top: AppSpacing.md)
                          : null,
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
        subtitle: const Text('online'),
        leading: UserStoriesAvatar(
          author: participant,
          enableUnactiveBorder: false,
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
