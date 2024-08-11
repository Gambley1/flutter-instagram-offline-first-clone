import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/attachments/widgets/widgets.dart';
import 'package:shared/shared.dart';

/// {@template url_attachment}
/// Displays a URL attachment.
/// {@endtemplate}
class UrlAttachment extends StatelessWidget {
  /// {@macro streamUrlAttachment}
  const UrlAttachment({
    required this.message,
    required this.urlAttachment,
    this.hostDisplayName,
    this.isMine = true,
    super.key,
  });

  /// The [Message] that the image is attached to.
  final Message message;

  /// Attachment to be displayed
  final Attachment urlAttachment;

  /// Host display name.
  final String? hostDisplayName;

  /// Whether the message this url attachment is attached to is mine.
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final accentColor = isMine ? AppColors.white : AppColors.deepBlue;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          stops: const [0.02, 0.02],
          colors: [accentColor, accentColor.withOpacity(.2)],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hostDisplayName != null)
            Text(
              hostDisplayName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyMedium?.copyWith(
                fontWeight: AppFontWeight.bold,
                color: AppColors.white,
              ),
            ),
          if (urlAttachment.title != null ||
              urlAttachment.title != hostDisplayName)
            Text(
              urlAttachment.title!.trim(),
              maxLines: 5,
              style: context.bodyMedium?.copyWith(
                fontWeight: AppFontWeight.bold,
                height: 1.2,
                wordSpacing: 0.5,
                color: AppColors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          if (urlAttachment.text != null)
            Text(
              urlAttachment.text!,
              maxLines: 5,
              style: context.bodyMedium
                  ?.copyWith(height: 1.3, color: AppColors.white),
              overflow: TextOverflow.ellipsis,
            ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: UrlAttachmentImage(urlAttachment: urlAttachment),
          ),
        ],
      ),
    );
  }
}

class UrlAttachmentImage extends StatelessWidget {
  const UrlAttachmentImage({
    required this.urlAttachment,
    super.key,
  });

  final Attachment urlAttachment;

  @override
  Widget build(BuildContext context) {
    // AppSpacing.md * 5 and AppSpacing.lg is the overall padding on the left
    // and right of the message content.
    final screenWidth =
        (context.screenWidth * .85) - (AppSpacing.md * 5) - AppSpacing.lg;
    final pixelRatio = context.devicePixelRatio;

    final thumbnailWidth = (screenWidth * pixelRatio) ~/ 1;
    final thumbnailHeight = (thumbnailWidth * (9 / 16)).toInt();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ImageAttachmentThumbnail(
        resizeWidth: thumbnailWidth,
        resizeHeight: thumbnailHeight,
        image: urlAttachment,
        borderRadius: 4,
        fit: BoxFit.cover,
      ),
    );
  }
}
