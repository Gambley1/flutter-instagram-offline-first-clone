import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

class RepliedMessageBubble extends StatelessWidget {
  const RepliedMessageBubble({
    required this.message,
    this.onTap,
    super.key,
  });

  final Message message;
  final ValueSetter<String>? onTap;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = message.sender?.id == user.id;

    final repliedMessage = message.repliedMessage;

    final repliedMessageUsername = message.replyMessageUsername;
    final replyMessageAttachmentUrl = message.replyMessageAttachmentUrl;
    final repliedMessageSharedPostDeleted =
        (replyMessageAttachmentUrl?.isEmpty ?? true) &&
            message.sharedPostId == null;

    final accentColor = isMine ? AppColors.white : AppColors.deepBlue;

    const imageHeight = 46.0;
    const imageWidth = 46.0;

    return Tappable(
      onTap: message.replyMessageId == null
          ? null
          : () => onTap?.call(message.replyMessageId!),
      animationEffect: TappableAnimationEffect.scale,
      scaleStrength: ScaleStrength.xxxxs,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: const [0.02, 0.02],
            colors: [accentColor, accentColor.withOpacity(.2)],
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!repliedMessageSharedPostDeleted) ...[
              ImageAttachmentThumbnail(
                image: Attachment(imageUrl: replyMessageAttachmentUrl),
                fit: BoxFit.cover,
                borderRadius: 4,
                width: imageWidth,
                height: imageHeight,
                withAdaptiveColors: false,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    repliedMessageUsername ?? 'Unknown',
                    style: context.bodyLarge?.copyWith(
                      color: accentColor,
                      fontWeight: AppFontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                  if (!(repliedMessage?.message.isEmpty ??
                      true &&
                          (repliedMessage?.sharedPost?.caption.trim().isEmpty ??
                              true)))
                    Text(
                      repliedMessage?.message ??
                          repliedMessage!.sharedPost!.caption,
                      style: context.bodyMedium?.apply(color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ].insertBetween(const SizedBox(width: AppSpacing.xs)),
        ),
      ),
    );
  }
}
