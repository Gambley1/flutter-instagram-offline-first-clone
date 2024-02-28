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
    _commentTextController =
        context.read<CommentsController>().commentTextController;

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
  Widget build(BuildContext context) {
    final user = context.select((AppBloc b) => b.state.user);
    final commentsController = context.read<CommentsController>();

    return Padding(
      padding: EdgeInsets.only(bottom: context.viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: commentsController.isCommentReplyingTo,
            builder: (context, isReplying, child) {
              return Offstage(
                offstage: !isReplying,
                child: ListTile(
                  tileColor: context.customReversedAdaptiveColor(
                    light: AppColors.brightGrey,
                    dark: AppColors.background,
                  ),
                  title: Text(
                    'Reply to ${commentsController.commentReplyingToUsername}',
                    style: context.bodyMedium?.apply(color: AppColors.grey),
                  ),
                  trailing: Tappable(
                    onTap: commentsController.clearReplying,
                    animationEffect: TappableAnimationEffect.none,
                    child: const Icon(Icons.cancel, color: AppColors.grey),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: commentEmojies
                      .map(
                        (emoji) => Flexible(
                          child: FittedBox(
                            child: TextEmoji(
                              emoji: emoji,
                              onEmojiTap: (emoji) {
                                _commentTextController
                                  ..text = _commentTextController.text + emoji
                                  ..selection = TextSelection.fromPosition(
                                    TextPosition(
                                      offset:
                                          _commentTextController.text.length,
                                    ),
                                  );
                              },
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                SafeArea(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    titleAlignment: ListTileTitleAlignment.titleHeight,
                    horizontalTitleGap: AppSpacing.md,
                    leading: UserProfileAvatar(
                      enableBorder: false,
                      isLarge: false,
                      onTap: (_) {},
                      avatarUrl: user.avatarUrl,
                      withShimmerPlaceholder: true,
                      withAdaptiveBorder: false,
                    ),
                    subtitle: AppTextField(
                      textController: _commentTextController,
                      focusNode: _focusNode,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Add a comment',
                      textInputType: TextInputType.text,
                      textInputAction: TextInputAction.newline,
                      autofillHints: const [AutofillHints.username],
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    trailing: AnimatedBuilder(
                      animation: Listenable.merge([_commentTextController]),
                      builder: (context, child) {
                        if (_commentTextController.text.trim().isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Tappable(
                          fadeStrength: FadeStrength.medium,
                          onTap: () {
                            if (_commentTextController.value.text.isEmpty) {
                              return;
                            }
                            context.read<CommentsBloc>().add(
                                  CommentsCommentCreateRequested(
                                    userId: user.id,
                                    content: _commentTextController.value.text,
                                    repliedToCommentId: commentsController
                                        .commentReplyingToCommentId,
                                  ),
                                );
                            if (commentsController.isReplying) {
                              commentsController.clearReplying();
                            }
                            _commentTextController.clear();
                          },
                          child: Text(
                            'Publish',
                            style:
                                context.bodyLarge?.apply(color: AppColors.blue),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
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
