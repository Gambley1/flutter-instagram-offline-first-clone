import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:intl/intl.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:shared/shared.dart';

class MessageBubbleContent extends StatelessWidget {
  const MessageBubbleContent({
    required this.message,
    this.onRepliedMessageTap,
    super.key,
  });

  final Message message;
  final ValueSetter<String>? onRepliedMessageTap;

  bool get hasNonUrlAttachments =>
      message.attachments.any((a) => a.type != AttachmentType.urlPreview.value);

  bool get hasUrlAttachments =>
      message.attachments.any((a) => a.type == AttachmentType.urlPreview.value);

  bool get hasAttachments => hasUrlAttachments || hasNonUrlAttachments;

  bool get hasRepliedMessage => message.repliedMessage != null;

  bool get displayBottomStatuses => hasAttachments;

  bool get isEdited =>
      message.createdAt.isAfter(message.updatedAt) &&
      !message.createdAt.isAtSameMomentAs(message.updatedAt);

  bool get isSharedPostUnavailable =>
      message.sharedPostId == null && message.message.trim().isEmpty;

  bool get hasSharedPost =>
      message.sharedPost != null &&
      message.replyMessageId == null &&
      message.replyMessageAttachmentUrl == null;

  bool get isSharedPostReel => message.sharedPost?.isReel ?? false;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = message.sender?.id == user.id;
    final sharedPost = message.sharedPost;

    final effectiveTextColor = switch ((isMine, context.isLight)) {
      (true, _) => AppColors.white,
      (false, true) => AppColors.black,
      (false, false) => AppColors.white,
    };

    return MessageBubbleBackground(
      colors: [
        if (!isMine) ...[
          context.customReversedAdaptiveColor(
            light: AppColors.white,
            dark: AppColors.primaryDarkBlue,
          ),
        ] else
          ...AppColors.primaryMessageBubbleGradient,
      ],
      child: switch ((
        isSharedPostUnavailable,
        hasSharedPost,
        isSharedPostReel
      )) {
        (true, _, _) => MessageSharedPostUnavailable(
            message: message,
            isEdited: isEdited,
            effectiveTextColor: effectiveTextColor,
          ),
        (false, true, true) => MessageSharedReel(
            sharedPost: sharedPost!,
            effectiveTextColor: effectiveTextColor,
            isEdited: isEdited,
            message: message,
          ),
        (false, true, false) => MessageSharedPost(
            sharedPost: sharedPost!,
            effectiveTextColor: effectiveTextColor,
            isEdited: isEdited,
            message: message,
          ),
        (false, false, _) => MessageContentView(
            message: message,
            isMine: isMine,
            isEdited: isEdited,
            hasAttachments: hasAttachments,
            effectiveTextColor: effectiveTextColor,
            onRepliedMessageTap: onRepliedMessageTap,
            hasRepliedMessage: hasRepliedMessage,
            displayBottomStatuses: displayBottomStatuses,
          ),
      },
    );
  }
}

class MessageContentView extends StatelessWidget {
  const MessageContentView({
    required this.hasRepliedMessage,
    required this.message,
    required this.displayBottomStatuses,
    required this.isMine,
    required this.effectiveTextColor,
    required this.isEdited,
    required this.hasAttachments,
    this.onRepliedMessageTap,
    super.key,
  });

  final Message message;
  final Color effectiveTextColor;
  final ValueSetter<String>? onRepliedMessageTap;
  final bool isMine;
  final bool isEdited;
  final bool hasRepliedMessage;
  final bool hasAttachments;
  final bool displayBottomStatuses;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasRepliedMessage)
                RepliedMessageBubble(
                  message: message,
                  onTap: onRepliedMessageTap,
                ),
              if (displayBottomStatuses)
                Padding(
                  padding: !hasRepliedMessage
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(
                          top: AppSpacing.xs,
                        ),
                  child: MessageTextBubble(
                    message: message,
                    isMine: isMine,
                    isOnlyEmoji: message.message.isOnlyEmoji,
                  ),
                )
              else
                TextMessageWidget(
                  text: message.message,
                  spacing: AppSpacing.md,
                  textStyle:
                      context.bodyLarge?.apply(color: effectiveTextColor),
                  child: MessageStatuses(
                    isEdited: isEdited,
                    message: message,
                  ),
                ),
              if (hasAttachments) ParseAttachments(message: message),
            ],
          ),
        ),
        if (displayBottomStatuses)
          Positioned.fill(
            right: AppSpacing.md,
            bottom: AppSpacing.xs,
            child: Align(
              alignment: Alignment.bottomRight,
              child: MessageStatuses(
                isEdited: isEdited,
                message: message,
              ),
            ),
          ),
      ],
    );
  }
}

class MessageSharedPost extends StatelessWidget {
  const MessageSharedPost({
    required this.sharedPost,
    required this.effectiveTextColor,
    required this.isEdited,
    required this.message,
    super.key,
  });

  final PostBlock sharedPost;
  final Color effectiveTextColor;
  final bool isEdited;
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Tappable(
          animationEffect: TappableAnimationEffect.none,
          onTap: () => context.pushNamed(
            'post',
            pathParameters: {'id': sharedPost.id},
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                horizontalTitleGap: AppSpacing.sm,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                leading: UserProfileAvatar(
                  avatarUrl: sharedPost.author.avatarUrl,
                  isLarge: false,
                ),
                title: Text(
                  sharedPost.author.username,
                  style: context.bodyLarge?.copyWith(
                    fontWeight: AppFontWeight.bold,
                    color: effectiveTextColor,
                  ),
                ),
              ),
              Stack(
                children: [
                  MessageSharedPostImage(sharedPost: sharedPost),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Builder(
                      builder: (_) {
                        if (sharedPost.isReel) {
                          return Assets.icons.instagramReel.svg(
                            height: AppSize.iconSizeBig,
                            width: AppSize.iconSizeBig,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          );
                        }
                        if (sharedPost.media.length > 1) {
                          return const Icon(
                            Icons.layers,
                            size: AppSize.iconSizeBig,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                              ),
                            ],
                          );
                        }
                        if (sharedPost.hasBothMediaTypes) {
                          return const SizedBox.shrink();
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
              if (sharedPost.caption.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text.rich(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: sharedPost.author.username,
                          style: context.bodyLarge?.copyWith(
                            fontWeight: AppFontWeight.bold,
                            color: effectiveTextColor,
                          ),
                        ),
                        const WidgetSpan(
                          child: Gap.h(AppSpacing.xs),
                        ),
                        TextSpan(
                          text: sharedPost.caption,
                          style: context.bodyLarge?.apply(
                            color: effectiveTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned.fill(
          right: AppSpacing.md,
          bottom: AppSpacing.xs,
          child: Align(
            alignment: Alignment.bottomRight,
            child: MessageStatuses(
              isEdited: isEdited,
              message: message,
            ),
          ),
        ),
      ],
    );
  }
}

class MessageSharedPostImage extends StatelessWidget {
  const MessageSharedPostImage({
    required this.sharedPost,
    super.key,
  });

  final PostBlock sharedPost;

  @override
  Widget build(BuildContext context) {
    final screenWidth = (context.screenWidth * .85) - AppSpacing.md * 2;
    final pixelRatio = context.devicePixelRatio;

    final thumbnailWidth = (screenWidth * pixelRatio) ~/ 1;
    return AspectRatio(
      aspectRatio: 1,
      child: ImageAttachmentThumbnail(
        resizeHeight: thumbnailWidth,
        image: Attachment(imageUrl: sharedPost.firstMediaUrl),
        fit: BoxFit.cover,
      ),
    );
  }
}

class MessageSharedReel extends StatelessWidget {
  const MessageSharedReel({
    required this.sharedPost,
    required this.effectiveTextColor,
    required this.isEdited,
    required this.message,
    super.key,
  });

  final PostBlock sharedPost;
  final Color effectiveTextColor;
  final bool isEdited;
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Tappable(
          animationEffect: TappableAnimationEffect.none,
          onTap: () => context.pushNamed(
            'post',
            pathParameters: {'id': sharedPost.id},
          ),
          child: Stack(
            children: [
              InViewNotifierWidget(
                id: message.id,
                builder: (context, isInView, _) {
                  return InlineVideo(
                    videoSettings: VideoSettings.build(
                      aspectRatio: 1,
                      shouldPlay: isInView,
                      id: sharedPost.id,
                      blurHash: sharedPost.firstMedia?.blurHash,
                      videoUrl: sharedPost.firstMedia?.url,
                      withSound: false,
                      withPlayerController: false,
                      withSoundButton: false,
                    ),
                  );
                },
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Builder(
                  builder: (_) {
                    if (sharedPost.media.length > 1) {
                      return const Icon(
                        Icons.layers,
                        size: AppSize.iconSizeBig,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                child: ListTile(
                  horizontalTitleGap: AppSpacing.sm,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  leading: UserProfileAvatar(
                    avatarUrl: sharedPost.author.avatarUrl,
                    isLarge: false,
                  ),
                  title: Text(
                    sharedPost.author.username,
                    style: context.bodyLarge?.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: effectiveTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Assets.icons.instagramReel.svg(
                    height: AppSize.iconSizeBig,
                    width: AppSize.iconSizeBig,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          right: AppSpacing.md,
          bottom: AppSpacing.xs,
          child: Align(
            alignment: Alignment.bottomRight,
            child: MessageStatuses(
              isEdited: isEdited,
              message: message,
            ),
          ),
        ),
      ],
    );
  }
}

class MessageSharedPostUnavailable extends StatelessWidget {
  const MessageSharedPostUnavailable({
    required this.effectiveTextColor,
    required this.message,
    required this.isEdited,
    super.key,
  });

  final Message message;
  final bool isEdited;
  final Color effectiveTextColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.postUnavailableText,
            style: context.bodyLarge?.copyWith(
              fontWeight: AppFontWeight.bold,
              color: effectiveTextColor,
            ),
          ),
          TextMessageWidget(
            text: '${l10n.postUnavailableDescriptionText}.',
            spacing: AppSpacing.md,
            textStyle: context.bodyLarge?.apply(color: effectiveTextColor),
            child: MessageStatuses(
              isEdited: isEdited,
              message: message,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStatuses extends StatelessWidget {
  const MessageStatuses({
    required this.isEdited,
    required this.message,
    super.key,
  });

  final Message message;
  final bool isEdited;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = message.sender?.id == user.id;

    final effectiveSecondaryTextColor = switch (isMine) {
      true => AppColors.white,
      false => AppColors.grey,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isEdited)
          Text(
            context.l10n.editedText,
            style: context.bodySmall?.apply(color: effectiveSecondaryTextColor),
          ),
        Text(
          message.createdAt.format(
            context,
            dateFormat: DateFormat.Hm,
          ),
          style: context.bodySmall?.apply(color: effectiveSecondaryTextColor),
        ),
        if (isMine) ...[
          if (message.isRead)
            Assets.icons.check.svg(
              height: AppSize.iconSizeSmall,
              width: AppSize.iconSizeSmall,
              colorFilter: ColorFilter.mode(
                effectiveSecondaryTextColor,
                BlendMode.srcIn,
              ),
            )
          else
            Icon(
              Icons.check,
              size: AppSize.iconSizeSmall,
              color: effectiveSecondaryTextColor,
            ),
        ],
      ].spacerBetween(width: AppSpacing.xs),
    );
  }
}
