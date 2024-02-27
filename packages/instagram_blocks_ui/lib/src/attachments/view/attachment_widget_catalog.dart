// ignore_for_file: comment_references

import 'package:flutter/widgets.dart';
import 'package:instagram_blocks_ui/src/attachments/widgets/widgets.dart';
import 'package:shared/shared.dart';

/// {@template attachment_widget_catalog}
/// A widget catalog which determines which attachment widget should be build
/// for a given [Message] and [Attachment] based on the list of [builders].
///
/// This is used by the [MessageBubble] to build the widget for the
/// [Message.attachments]. If you want to customize the widget used to show
/// attachments, you can use this to add your own attachment builder.
/// {@endtemplate}
class AttachmentWidgetCatalog {
  /// {@macro attachment_widget_catalog}
  const AttachmentWidgetCatalog({required this.builders});

  /// The list of builders to use to build the widget.
  ///
  /// The order of the builders is important. The first builder that can handle
  /// the message and attachments will be used to build the widget.
  final List<AttachmentWidgetBuilder> builders;

  /// Builds a widget for the given [message] and [attachments].
  ///
  /// It iterates through the list of builders and uses the first builder
  /// that can handle the message and attachments.
  ///
  /// Throws an [Exception] if no builder is found for the message.
  Widget build(BuildContext context, Message message, {required bool isMine}) {
    assert(!message.isDeleted, 'Cannot build attachment for deleted message');

    assert(
      message.attachments.isNotEmpty,
      'Cannot build attachment for message without attachments',
    );

    // The list of attachments to build the widget for.
    final attachments = message.attachments.grouped;
    for (final builder in builders) {
      if (builder.canHandle(message, attachments)) {
        return builder.build(context, message, attachments, isMine: isMine);
      }
    }

    throw Exception('No builder found for $message and $attachments');
  }
}

extension on List<Attachment> {
  Map<T, List<S>> groupBy<S, T>(Iterable<S> values, T Function(S) key) {
    final map = <T, List<S>>{};
    for (final element in values) {
      (map[key(element)] ??= []).add(element);
    }
    return map;
  }

  /// Groups the attachments by their type.
  Map<String, List<Attachment>> get grouped {
    return groupBy(
      where((it) {
        return it.type != null;
      }),
      (attachment) => attachment.type!,
    );
  }
}
