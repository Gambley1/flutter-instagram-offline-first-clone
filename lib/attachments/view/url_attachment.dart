import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/attachments/widgets/thumnail/thumbnail.dart';
import 'package:shared/shared.dart';

/// {@template streamUrlAttachment}
/// Displays a URL attachment.
/// {@endtemplate}
class UrlAttachment extends StatelessWidget {
  /// {@macro streamUrlAttachment}
  const UrlAttachment({
    required this.message,
    required this.urlAttachment,
    this.hostDisplayName,
    super.key,
    this.shape,
    this.constraints = const BoxConstraints(),
  });

  /// The [Message] that the image is attached to.
  final Message message;

  /// Attachment to be displayed
  final Attachment urlAttachment;

  /// The shape of the attachment.
  ///
  /// Defaults to [RoundedRectangleBorder] with a radius of 14.
  final ShapeBorder? shape;

  /// The constraints to use when displaying the file.
  final BoxConstraints constraints;

  /// Host display name.
  final String? hostDisplayName;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = message.sender?.id == user.id;

    final accentColor = isMine ? AppColors.white : const Color(0xff337eff);

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
            child: AspectRatio(
              aspectRatio: urlAttachment.aspectRatio,
              child: ImageAttachmentThumbnail(
                height: urlAttachment.originalHeight?.toDouble(),
                width: urlAttachment.originalWidth?.toDouble(),
                image: urlAttachment,
                borderRadius: 4,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
