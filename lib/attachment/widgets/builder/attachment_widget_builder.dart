import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/attachment/view/view.dart';
import 'package:shared/shared.dart';

part 'fallback_attachment_builder.dart';
part 'image_attachment_builder.dart';
part 'mixed_attachment_builder.dart';
part 'url_attachment_builder.dart';

typedef AttachmentWidgetTapCallback = void Function(
  Message message,
  Attachment attachment,
);

enum AttachmentAlignment {
  top('top'),
  bottom('bottom');

  const AttachmentAlignment(this.value);

  final String value;

  bool get isAtTop => this == AttachmentAlignment.top;

  bool get isAtBottom => this == AttachmentAlignment.bottom;
}

abstract class AttachmentWidgetBuilder {
  /// {@macro attachmentWidgetBuilder}
  const AttachmentWidgetBuilder();

  static List<AttachmentWidgetBuilder> defaultBuilders({
    required Message message,
    ShapeBorder? shape,
    EdgeInsetsGeometry padding = const EdgeInsets.all(4),
    AttachmentWidgetTapCallback? onAttachmentTap,
  }) {
    return [
      // Handles a mix of image, gif, video, url and file attachments.
      MixedAttachmentBuilder(
        padding: padding,
        onAttachmentTap: onAttachmentTap,
      ),

      // We don't handle URL attachments if the message is a reply.
      UrlAttachmentBuilder(
        shape: shape,
        onAttachmentTap: onAttachmentTap,
      ),

      // Fallback builder should always be the last builder in the list.
      const FallbackAttachmentBuilder(),
    ];
  }

  /// Determines whether this builder can handle the given [message] and
  /// [attachments]. If this returns `true`, [build] will be called.
  /// Otherwise, the next builder in the list will be called.
  bool canHandle(Message message, Map<String, List<Attachment>> attachments);

  /// Builds a widget for the given [message] and [attachments].
  /// This will only be called if [canHandle] returns `true`.
  Widget build(
    BuildContext context,
    Message message,
    Map<String, List<Attachment>> attachments,
  );

  /// Asserts that this builder can handle the given [message] and
  /// [attachments].
  ///
  /// This is used to ensure that the [defaultBuilders] are used correctly.
  ///
  /// **Note**: This method is only called in debug mode.
  bool debugAssertCanHandle(
    Message message,
    Map<String, List<Attachment>> attachments,
  ) {
    assert(
      () {
        if (!canHandle(message, attachments)) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
              'A $runtimeType was used to build a attachment for a message, but '
              'it cant handle the message.',
            ),
            ErrorDescription(
              'The builders in the list must be checked in order. Check the '
              'documentation for $runtimeType for more details.',
            ),
          ]);
        }
        return true;
      }(),
      '',
    );
    return true;
  }
}
