import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/attachment/view/view.dart';
import 'package:flutter_instagram_offline_first_clone/attachment/widgets/attachment_package.dart';
import 'package:flutter_instagram_offline_first_clone/attachment/widgets/builder/builder.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class ParseAttachments extends StatelessWidget {
  /// {@macro parseAttachments}
  const ParseAttachments({
    required this.message,
    // required this.attachmentBuilders,
    // required this.attachmentPadding,
    super.key,
    this.attachmentShape,
    this.onAttachmentTap,
    // this.onShowMessage,
    this.onReplyTap,
    // this.attachmentActionsModalBuilder,
  });

  /// {@macro message}
  final Message message;

  /// {@macro attachmentBuilders}
  // final List<AttachmentWidgetBuilder>? attachmentBuilders;

  /// {@macro attachmentPadding}
  // final EdgeInsetsGeometry attachmentPadding;

  /// {@macro attachmentShape}
  final ShapeBorder? attachmentShape;

  /// {@macro onAttachmentTap}
  final AttachmentWidgetTapCallback? onAttachmentTap;

  /// {@macro onShowMessage}
  // final ShowMessageCallback? onShowMessage;

  /// {@macro onReplyTap}
  final void Function(Message)? onReplyTap;

  /// {@macro attachmentActionsBuilder}
  // final AttachmentActionsBuilder? attachmentActionsModalBuilder;

  @override
  Widget build(BuildContext context) {
    // Create a default onAttachmentTap callback if not provided.
    var onAttachmentTap = this.onAttachmentTap;
    onAttachmentTap ??= (message, attachment) {
      // If the current attachment is a url preview attachment, open the url
      // in the browser.
      final isUrlPreview = attachment.type == AttachmentType.urlPreview.value;
      if (isUrlPreview) {
        final url = attachment.ogScrapeUrl ?? '';
        launchURL(context, url);
        return;
      }

      final isImage = attachment.type == AttachmentType.image.value;
      final isVideo = attachment.type == AttachmentType.video.value;
      final isGiphy = attachment.type == AttachmentType.giphy.value;

      // If the current attachment is a media attachment, open the media
      // attachment in full screen.
      final isMedia = isImage || isVideo || isGiphy;
      if (isMedia) {
        // final attachments = message.toAttachmentPackage(
        //   filter: (it) {
        //     final isImage = it.type == AttachmentType.image;
        //     final isVideo = it.type == AttachmentType.video;
        //     final isGiphy = it.type == AttachmentType.giphy;
        //     return isImage || isVideo || isGiphy;
        //   },
        // );

        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) {
        //       return StreamChannel(
        //         channel: channel,
        //         child: StreamFullScreenMediaBuilder(
        //           userName: message.user!.name,
        //           mediaAttachmentPackages: attachments,
        //           startIndex: attachments.indexWhere(
        //             (it) => it.attachment.id == attachment.id,
        //           ),
        //           onReplyMessage: onReplyTap,
        //           onShowMessage: onShowMessage,
        //           attachmentActionsModalBuilder: attachmentActionsModalBuilder,
        //         ),
        //       );
        //     },
        //   ),
        // );

        return;
      }
    };

    // Create a default attachmentBuilders list if not provided.
    // var builders = attachmentBuilders;
    final builders = AttachmentWidgetBuilder.defaultBuilders(
      message: message,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      onAttachmentTap: onAttachmentTap,
    );

    final catalog = AttachmentWidgetCatalog(builders: builders);
    return catalog.build(context, message);
  }
}

extension on Message {
  List<AttachmentPackage> toAttachmentPackage({
    bool Function(Attachment)? filter,
  }) {
    // Create a copy of the attachments list.
    var attachments = [...this.attachments];
    if (filter != null) {
      attachments = [...attachments.where(filter)];
    }

    // Create a list of StreamAttachmentPackage from the attachments list.
    return [
      ...attachments.map((it) {
        return AttachmentPackage(
          attachment: it,
          message: this,
        );
      }),
    ];
  }
}

Future<void> launchURL(BuildContext context, String url) async {
  try {
    await launchUrl(
      Uri.parse(url).withScheme,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    openSnackbar(
      SnackbarMessage(
        title: 'Failed to open the url.',
        icon: Icons.sms_failed_outlined,
      ),
    );
  }
}
