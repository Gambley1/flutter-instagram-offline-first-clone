import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comments.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

class CommentTextField extends StatefulWidget {
  const CommentTextField({
    required this.controller,
    required this.postId,
    super.key,
  });

  final String postId;
  final DraggableScrollableController controller;

  @override
  State<CommentTextField> createState() => _CommentTextFieldState();
}

class _CommentTextFieldState extends State<CommentTextField> {
  late TextEditingController _commentTextController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _commentTextController = TextEditingController();
    context.read<CommentsController>().commentTextController =
        _commentTextController;

    _focusNode = context.read<CommentsController>().commentFocusNode;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (!widget.controller.isAttached) return;
        if (widget.controller.size == 1.0) return;
        widget.controller.animateTo(
          1,
          duration: 250.ms,
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc b) => b.state.user);
    final commentsController = context.read<CommentsController>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: commentsController.isCommentReplyingTo,
            builder: (context, isReplying, child) {
              return Offstage(
                offstage: !isReplying,
                child: ListTile(
                  tileColor: Colors.grey.shade900,
                  title: Text(
                    'Reply to ${commentsController.commentReplyingToUsername}',
                    style: context.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  trailing: Tappable(
                    onTap: () => setState(commentsController.clearReplying),
                    animationEffect: TappableAnimationEffect.none,
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: commentEmojies
                .map(
                  (emoji) => Flexible(
                    child: FittedBox(
                      child: TextEmoji(
                        emoji: emoji,
                        onEmojiTap: (emoji) {
                          setState(() {
                            _commentTextController
                              ..text = _commentTextController.text + emoji
                              ..selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: _commentTextController.text.length,
                                ),
                              );
                          });
                        },
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(
              bottom: AppSpacing.lg,
              right: AppSpacing.xs,
            ),
            titleAlignment: ListTileTitleAlignment.titleHeight,
            leading: UserProfileAvatar(
              enableBorder: false,
              isLarge: false,
              onTap: (_) {},
              avatarUrl: user.avatarUrl,
              withShimmerPlaceholder: true,
            ),
            subtitle: AppTextField(
              textController: _commentTextController,
              onChanged: (val) {
                setState(() {
                  _commentTextController.text = val;
                });
              },
              hintText: 'Add a comment',
              textInputType: TextInputType.text,
              textInputAction: TextInputAction.newline,
              focusNode: _focusNode,
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            trailing: _commentTextController.text.isEmpty
                ? null
                : Tappable(
                    fadeStrength: FadeStrength.medium,
                    onTap: () {
                      if (_commentTextController.value.text.isEmpty) return;
                      context.read<CommentsBloc>().add(
                            CommentsCommentCreateRequested(
                              userId: user.id,
                              content: _commentTextController.value.text,
                              repliedToCommentId:
                                  commentsController.commentReplyingToCommentId,
                            ),
                          );
                      if (commentsController.isReplying) {
                        commentsController.clearReplying();
                      }
                      setState(_commentTextController.clear);
                    },
                    child: Text(
                      'Publish',
                      style: context.bodyLarge
                          ?.copyWith(color: Colors.blue.shade500),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class TextEmoji extends StatelessWidget {
  const TextEmoji({
    required this.emoji,
    required this.onEmojiTap,
    super.key,
  });

  final String emoji;
  final ValueSetter<String> onEmojiTap;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      animationEffect: TappableAnimationEffect.scale,
      onTap: () => onEmojiTap(emoji),
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.xlg),
        child: Text(
          emoji,
          style: context.displayMedium,
        ),
      ),
    );
  }
}
