part of 'attachment_widget_builder.dart';

/// {@template url_attachment_builder}
/// A widget builder for url attachment type.
///
/// This is used to show url attachments with a preview.
/// etc.
/// {@endtemplate}
class UrlAttachmentBuilder extends AttachmentWidgetBuilder {
  /// {@macro url_attachment_builder}
  const UrlAttachmentBuilder({
    this.padding,
    this.onAttachmentTap,
    this.attachmentAlignment = AttachmentAlignment.bottom,
  });

  /// The padding to apply to the url attachment widget.
  final EdgeInsetsGeometry? padding;

  /// The callback to call when the attachment is tapped.
  final AttachmentWidgetTapCallback? onAttachmentTap;

  /// The alignment of the attachment. Whether to be displayed on top or
  /// at the bottom of the message.
  final AttachmentAlignment attachmentAlignment;

  @override
  bool canHandle(
    Message message,
    Map<String, List<Attachment>> attachments,
  ) {
    final urls = attachments[AttachmentType.urlPreview.value];
    return urls != null && urls.isNotEmpty;
  }

  @override
  Widget build(
    BuildContext context,
    Message message,
    Map<String, List<Attachment>> attachments, {
    required bool isMine,
  }) {
    assert(debugAssertCanHandle(message, attachments), '');

    final urlPreviews = attachments[AttachmentType.urlPreview.value]!;

    Widget buildUrlPreview(Attachment urlPreview) {
      VoidCallback? onTap;
      if (onAttachmentTap != null) {
        onTap = () => onAttachmentTap!(message, urlPreview);
      }

      var hostDisplayName = urlPreview.authorName?.capitalize;
      if (urlPreview.titleLink != null && hostDisplayName == null) {
        final host =
            urlPreview.authorName ?? Uri.parse(urlPreview.titleLink!).host;
        final splitList = host.split('.');
        final hostName = splitList.length == 3 ? splitList[1] : splitList[0];
        hostDisplayName = hostName.getWebsiteName ?? hostName.capitalize;
      }

      return Tappable.scaled(
        onTap: onTap,
        scaleStrength: ScaleStrength.xxxs,
        child: UrlAttachment(
          message: message,
          urlAttachment: urlPreview,
          hostDisplayName: hostDisplayName,
          isMine: isMine,
        ),
      );
    }

    final padding = (this.padding) ??
        (attachmentAlignment.isAtBottom
            ? const EdgeInsets.only(top: AppSpacing.sm)
            : const EdgeInsets.only(bottom: AppSpacing.sm));

    Widget child;
    if (urlPreviews.length == 1) {
      child = buildUrlPreview(urlPreviews.first);
    } else {
      child = Column(
        children: <Widget>[
          for (final urlPreview in urlPreviews) buildUrlPreview(urlPreview),
        ].spacerBetween(
          // Add a small vertical padding between each attachment.
          height: padding.vertical / 2,
        ),
      );
    }

    return Padding(padding: padding, child: child);
  }
}
