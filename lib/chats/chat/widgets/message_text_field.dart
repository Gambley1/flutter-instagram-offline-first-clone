import 'package:app_ui/app_ui.dart';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/bloc/chat_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message_input_controller.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:ogp_data_extract/ogp_data_extract.dart';
import 'package:shared/shared.dart';

class ChatMessageTextField extends StatelessWidget {
  const ChatMessageTextField({
    required this.scrollController,
    required this.focusNode,
    required this.chat,
    this.messageInputController,
    this.restorationId,
    super.key,
  });

  final MessageInputController? messageInputController;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final String? restorationId;
  final ChatInbox chat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ChatMessageTextFieldInput(
                  messageInputController: messageInputController,
                  focusNode: focusNode,
                  scrollController: scrollController,
                  chat: chat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatMessageTextFieldInput extends StatefulWidget {
  const ChatMessageTextFieldInput({
    required this.focusNode,
    required this.scrollController,
    required this.chat,
    this.messageInputController,
    this.restorationId,
    super.key,
  });

  final MessageInputController? messageInputController;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final String? restorationId;
  final ChatInbox chat;

  @override
  State<ChatMessageTextFieldInput> createState() =>
      _ChatMessageTextFieldInputState();
}

class _ChatMessageTextFieldInputState extends State<ChatMessageTextFieldInput>
    with RestorationMixin<ChatMessageTextFieldInput>, WidgetsBindingObserver {
  final _debouncer = Debouncer(milliseconds: 350);

  MessageInputController get _effectiveController =>
      widget.messageInputController ?? _controller!.value;
  RestorableMessageInputController? _controller;

  void _createLocalController([Message? message]) {
    assert(_controller == null, '');
    _controller = RestorableMessageInputController(message: message);
  }

  void _registerController() {
    assert(_controller != null, '');

    registerForRestoration(_controller!, 'messageInputController');
    _effectiveController
      ..removeListener(_onChangedDebounced)
      ..addListener(_onChangedDebounced);
  }

  void _initialiseEffectiveController() {
    _effectiveController
      ..removeListener(_onChangedDebounced)
      ..addListener(_onChangedDebounced);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.messageInputController == null) {
      _createLocalController();
    } else {
      _initialiseEffectiveController();
    }
    widget.focusNode.addListener(_focusNodeListener);
  }

  @override
  void didUpdateWidget(covariant ChatMessageTextFieldInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messageInputController == null &&
        oldWidget.messageInputController != null) {
      _createLocalController(oldWidget.messageInputController!.message);
    } else if (widget.messageInputController != null &&
        oldWidget.messageInputController == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
      _initialiseEffectiveController();
    }

    // Update _focusNode
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode).removeListener(_focusNodeListener);
      (widget.focusNode).addListener(_focusNodeListener);
    }
  }

  void _focusNodeListener() {}

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void dispose() {
    _debouncer.dispose();
    _effectiveController.removeListener(_onChangedDebounced);
    _controller?.dispose();
    widget.focusNode.removeListener(_focusNodeListener);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    void onSend() {
      final wasEditing = _effectiveController.editingMessage != null;
      void sendMessage(Message message) {
        context.read<ChatBloc>().add(
              ChatSendMessageRequested(
                message: message,
                receiver: widget.chat.participant,
                sender: user,
              ),
            );
      }

      void updateMessage({
        required Message oldMessage,
        required Message newMessage,
      }) {
        context.read<ChatBloc>().add(
              ChatMessageEditRequested(
                oldMessage: oldMessage,
                newMessage: newMessage,
              ),
            );
      }

      if (_effectiveController.message.message.trim().isEmpty) return;
      final message = _effectiveController.message;
      if (wasEditing) {
        updateMessage(
          oldMessage: _effectiveController.editingMessage!,
          newMessage: message,
        );
      } else {
        sendMessage(message);
      }

      setState(_effectiveController.resetAll);
      widget.focusNode.requestFocus();
      if (!wasEditing) {
        widget.scrollController.animateTo(
          widget.scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeIn,
        );
      }
    }

    return ValueListenableBuilder(
      valueListenable: _effectiveController,
      builder: (context, value, child) {
        return Column(
          children: [
            MessagePreview(controller: _effectiveController),
            const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
            AppTextField(
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              focusNode: widget.focusNode,
              textController: _effectiveController.textFieldController,
              prefixIcon: const Icon(Icons.emoji_emotions_outlined),
              suffixIcon: _effectiveController.text.trim().isEmpty
                  ? null
                  : ChatSendMessageButton(
                      message: _effectiveController.text,
                      onSendMessage: onSend,
                    ),
              onFieldSubmitted: (_) => onSend.call(),
              onChanged: (value) =>
                  setState(() => _effectiveController.text = value),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              textInputType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              textAlignVertical: TextAlignVertical.center,
              maxLines: 5,
              minLines: 1,
              hintText: 'Message...',
            ),
          ],
        );
      },
    );
  }

  void _onChangedDebounced() => _debouncer.run(
        () {
          var value = _effectiveController.text;
          if (!mounted) return;
          value = value.trim();

          // final channel = StreamChannel.of(context).channel;
          // if (value.isNotEmpty &&
          //     channel.ownCapabilities.contains(PermissionType.sendTypingEvents)) {
          //   // Notify the server that the user started typing.
          //   channel
          //       .keyStroke(_effectiveController.message.parentId)
          //       .onError(
          //     (error, stackTrace) {
          //       widget.onError?.call(error!, stackTrace);
          //     },
          //   );
          // }

          // var actionsLength = widget.actions.length;
          // if (widget.showCommandsButton) actionsLength += 1;
          // if (!widget.disableAttachments) actionsLength += 1;

          // setState(() => _actionsShrunk = value.isNotEmpty && actionsLength > 1);

          _checkContainsUrl(value, context);
        },
      );

  String? _lastSearchedContainsUrlText;
  CancelableOperation<dynamic>? _enrichUrlOperation;
  final _urlRegex = RegExp(
    r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
    caseSensitive: false,
  );

  Future<void> _checkContainsUrl(String value, BuildContext context) async {
    // Cancel the previous operation if it's still running
    await _enrichUrlOperation?.cancel();

    // If the text is same as the last time, don't do anything
    if (_lastSearchedContainsUrlText == value) return;
    _lastSearchedContainsUrlText = value;

    final matchedUrls = _urlRegex.allMatches(value).where((it) {
      final parsedMatch = Uri.tryParse(it.group(0) ?? '')?.withScheme;
      if (parsedMatch == null) return false;

      return parsedMatch.host.split('.').last.isValidTLD();
      // &&
      // widget.ogPreviewFilter.call(_parsedMatch, value);
    }).toList();

    // Reset the og attachment if the text doesn't contain any url
    // if (matchedUrls.isEmpty ||
    //     !StreamChannel.of(context)
    //         .channel
    //         .ownCapabilities
    //         .contains(PermissionType.sendLinks)) {
    //   _effectiveController.clearOGAttachment();
    //   return;
    // }

    if (matchedUrls.isEmpty) {
      if (_effectiveController.ogAttachment != null) {
        _effectiveController.clearOGAttachment();
        return;
      }
      return;
    }

    final firstMatchedUrl = matchedUrls.first.group(0)!;

    // If the parsed url matches the ogAttachment url, don't do anything
    if (_effectiveController.ogAttachment?.titleLink == firstMatchedUrl) {
      return;
    }

    _enrichUrlOperation = CancelableOperation.fromFuture(
      _enrichUrl(firstMatchedUrl),
    ).then(
      (ogAttachment) {
        final attachment = Attachment.fromOGAttachment(ogAttachment);
        // if (_ogAttachmentCache[firstMatchedUrl] == ogAttachment &&
        // _effectiveController.editingMessage != null) return;
        _effectiveController.setOGAttachment(attachment);
      },
      onError: (error, stackTrace) {
        _effectiveController.clearOGAttachment();
      },
    );
  }

  final _ogAttachmentCache = <String, OGAttachment>{};

  Future<OGAttachment> _enrichUrl(
    String url,
  ) async {
    var response = _ogAttachmentCache[url];
    if (response == null) {
      try {
        final ogp = await OgpDataExtract.execute(url);
        if (ogp == null) {
          return Future.error("The page doesn't contain any OG data.");
        }
        final isEmpty =
            ogp.title == null && ogp.description == null && ogp.url == null;
        if (isEmpty) {
          return Future.error(
            "The page doesn't contain any title, description or url.",
          );
        }
        response = OGAttachment.fromOgpAttachment(ogp: ogp);
        _ogAttachmentCache[url] = response;
      } catch (e, stk) {
        return Future.error(e, stk);
      }
    }
    return response;
  }
}

class MessagePreview extends StatelessWidget {
  const MessagePreview({required this.controller, super.key});

  final MessageInputController controller;

  @override
  Widget build(BuildContext context) {
    late final hasEditingMessage = controller.editingMessage != null;
    late final hasOGAttachment = controller.ogAttachment != null;
    late final hasReplyingMessage = controller.replyingMessage != null;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.bottomCenter,
      child: Column(
        children: [
          if (hasOGAttachment || hasReplyingMessage || hasEditingMessage)
            const AppDivider(),
          if (hasOGAttachment)
            OGAttachmentPreview(
              onDismissPreviewPressed: controller.clearOGAttachment,
              attachment: controller.ogAttachment!,
            )
          else if (hasReplyingMessage)
            ReplyMessagePreview(
              onDismissPreviewPressed: controller.clearReplyingMessage,
              replyingMessage: controller.replyingMessage!,
            )
          else if (hasEditingMessage)
            EditingMessagePreview(
              onDismissEditingMessage: controller.clearEditingMessage,
              editingMessage: controller.editingMessage!,
            ),
        ],
      ),
    );
  }
}

class ChatSendMessageButton extends StatelessWidget {
  const ChatSendMessageButton({
    required this.message,
    required this.onSendMessage,
    super.key,
  });

  final String message;
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onSendMessage,
      child: const FittedBox(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Icon(Icons.send),
        ),
      ),
    );
  }
}

/// Preview of a reply message.
class ReplyMessagePreview extends StatelessWidget {
  /// Returns a new instance of [ReplyMessagePreview]
  const ReplyMessagePreview({
    required this.replyingMessage,
    super.key,
    this.onDismissPreviewPressed,
  });

  /// The message to be displayed.
  final Message replyingMessage;

  /// Called when the dismiss button is pressed.
  final VoidCallback? onDismissPreviewPressed;

  @override
  Widget build(BuildContext context) {
    final replyingText = replyingMessage.sharedPost == null
        ? replyingMessage.message
        : '${replyingMessage.sharedPost?.author.username} '
            '${replyingMessage.sharedPost?.caption}';
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm),
          child: Icon(
            Icons.reply_rounded,
            color: Color(0xff337eff),
          ),
        ),
        Expanded(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + AppSpacing.xxs,
            ),
            leading: replyingMessage.replyMessageAttachmentUrl == null ||
                    replyingMessage.replyMessageId != null
                ? null
                : CachedNetworkImage(
                    imageUrl: replyingMessage.replyMessageAttachmentUrl!,
                    placeholder: (_, __) => const ShimmerPlaceholder(
                      height: 52,
                      width: 52,
                      withAdaptiveColors: false,
                    ),
                    errorWidget: (context, url, error) =>
                        Assets.images.placeholder.image(
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
            title: replyingMessage.replyMessageUsername == null
                ? null
                : Text(
                    'Replying to ${replyingMessage.replyMessageUsername}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyLarge?.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: const Color(0xff337eff),
                    ),
                  ),
            subtitle: replyingMessage.message.isEmpty &&
                    replyingMessage.sharedPost == null
                ? null
                : Text(
                    replyingText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyMedium?.copyWith(
                      fontWeight: AppFontWeight.regular,
                      color: Colors.white,
                    ),
                  ),
            trailing: Tappable(
              onTap: onDismissPreviewPressed,
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Preview of an editing message.
class EditingMessagePreview extends StatelessWidget {
  /// Returns a new instance of [EditingMessagePreview]
  const EditingMessagePreview({
    required this.editingMessage,
    super.key,
    this.onDismissEditingMessage,
  });

  /// The message to be displayed.
  final Message editingMessage;

  /// Called when the dismiss button is pressed.
  final VoidCallback? onDismissEditingMessage;

  @override
  Widget build(BuildContext context) {
    if (editingMessage.message.trim().isEmpty) return const SizedBox.shrink();
    return ListTile(
      minVerticalPadding: 0,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xxs,
      ),
      leading: const Icon(
        Icons.edit_outlined,
        color: Color(0xff337eff),
      ),
      title: Text(
        'Editing',
        style: context.bodyLarge?.copyWith(
          fontWeight: AppFontWeight.bold,
          color: const Color(0xff337eff),
        ),
      ),
      subtitle: Text(
        editingMessage.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.bodyMedium?.copyWith(
          fontWeight: AppFontWeight.regular,
          color: Colors.white,
        ),
      ),
      trailing: Tappable(
        onTap: onDismissEditingMessage,
        child: const Icon(
          Icons.close,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Preview of an Open Graph attachment.
class OGAttachmentPreview extends StatelessWidget {
  /// Returns a new instance of [OGAttachmentPreview]
  const OGAttachmentPreview({
    required this.attachment,
    super.key,
    this.onDismissPreviewPressed,
  });

  /// The attachment to be rendered.
  final Attachment attachment;

  /// Called when the dismiss button is pressed.
  final VoidCallback? onDismissPreviewPressed;

  @override
  Widget build(BuildContext context) {
    final attachmentTitle = attachment.authorName ?? attachment.title;
    final attachmentText = attachment.text;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xxs,
      ),
      leading: const Icon(
        Icons.link,
        color: Color(0xff337eff),
      ),
      title: attachmentTitle == null
          ? null
          : Text(
              attachmentTitle.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyLarge?.copyWith(
                fontWeight: AppFontWeight.bold,
                color: const Color(0xff337eff),
              ),
            ),
      subtitle: attachmentText == null
          ? null
          : Text(
              attachmentText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyMedium
                  ?.copyWith(fontWeight: AppFontWeight.regular),
            ),
      trailing: Tappable(
        onTap: onDismissPreviewPressed,
        child: const Icon(
          Icons.close,
          color: Colors.white,
        ),
      ),
    );
  }
}
