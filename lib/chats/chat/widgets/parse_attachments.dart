import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/attachments/attachments.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class ParseAttachments extends StatelessWidget {
  /// {@macro parse_attachments}
  const ParseAttachments({
    required this.message,
    super.key,
    this.attachmentShape,
    this.onAttachmentTap,
  });

  /// {@macro message}
  final Message message;

  /// {@macro attachmentShape}
  final ShapeBorder? attachmentShape;

  /// {@macro onAttachmentTap}
  final AttachmentWidgetTapCallback? onAttachmentTap;

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
      }
    };

    // Create a default attachmentBuilders list if not provided.
    // var builders = attachmentBuilders;
    final builders = AttachmentWidgetBuilder.defaultBuilders(
      message: message,
      onAttachmentTap: onAttachmentTap,
    );

    final catalog = AttachmentWidgetCatalog(builders: builders);
    return catalog.build(context, message);
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
      const SnackbarMessage.error(title: 'Failed to open the url.'),
    );
  }
}
