import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comments.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';

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
  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc b) => b.state.user);
    final commentInputController =
        CommentsPage.of(context).commentInputController;

    return Padding(
      padding: EdgeInsets.only(bottom: context.viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListenableBuilder(
            listenable: commentInputController,
            builder: (context, child) {
              return Offstage(
                offstage: !commentInputController.isReplying,
                child: ListTile(
                  tileColor: context.customReversedAdaptiveColor(
                    light: AppColors.brightGrey,
                    dark: AppColors.background,
                  ),
                  title: Text(
                    context.l10n.replyToText(
                      commentInputController.replyingUsername ?? 'unknown',
                    ),
                    style: context.bodyMedium?.apply(color: AppColors.grey),
                  ),
                  trailing: Tappable(
                    onTap: commentInputController.clear,
                    animationEffect: TappableAnimationEffect.none,
                    child: const Icon(Icons.cancel, color: AppColors.grey),
                  ),
                ),
              );
            },
          ),
          const Gap.v(AppSpacing.md),
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
                              onEmojiTap: commentInputController.onEmojiTap,
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
                    ),
                    subtitle: AppTextField(
                      textController:
                          commentInputController.commentTextController,
                      focusNode: commentInputController.commentFocusNode,
                      contentPadding: EdgeInsets.zero,
                      hintText: context.l10n.addCommentText,
                      textInputType: TextInputType.text,
                      textInputAction: TextInputAction.newline,
                      autofillHints: const [AutofillHints.username],
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    trailing: ListenableBuilder(
                      listenable: commentInputController.commentTextController,
                      builder: (context, _) {
                        if (commentInputController.commentTextController.text
                            .trim()
                            .isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Tappable(
                          fadeStrength: FadeStrength.medium,
                          onTap: () {
                            if (commentInputController
                                .commentTextController.value.text.isEmpty) {
                              return;
                            }
                            context.read<CommentsBloc>().add(
                                  CommentsCommentCreateRequested(
                                    userId: user.id,
                                    content: commentInputController
                                        .commentTextController.value.text,
                                    repliedToCommentId: commentInputController
                                        .replyingCommentId,
                                  ),
                                );
                            commentInputController.clear();
                          },
                          child: Text(
                            context.l10n.publishText,
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
