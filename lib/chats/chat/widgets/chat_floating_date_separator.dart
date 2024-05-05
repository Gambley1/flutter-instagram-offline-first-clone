import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/chat.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared/shared.dart';

/// {@template floating_date_separator}
/// Not intended for use outside of [ChatMessagesListView].
/// {@endtemplate}
class ChatFloatingDateSeparator extends StatelessWidget {
  /// {@macro floating_date_separator}
  const ChatFloatingDateSeparator({
    required this.itemPositionsListener,
    required this.reverse,
    required this.messages,
    required this.itemCount,
    super.key,
    this.dateSeparatorBuilder,
  });

  final ValueListenable<Iterable<ItemPosition>> itemPositionsListener;

  final bool reverse;

  final List<Message> messages;

  final int itemCount;

  final Widget Function(DateTime date)? dateSeparatorBuilder;

  /// Gets the index of the top element in the viewport.
  static int? _getTopElementIndex(Iterable<ItemPosition> values) {
    final inView = values.where((position) => position.itemLeadingEdge < 1);
    if (inView.isEmpty) return null;
    return inView
        .reduce(
          (max, position) =>
              position.itemLeadingEdge > max.itemLeadingEdge ? position : max,
        )
        .index;
  }

  /// Gets the index of the bottom element in the viewport.
  static int? _getBottomElementIndex(Iterable<ItemPosition> values) {
    final inView = values.where((position) => position.itemLeadingEdge < 1);
    if (inView.isEmpty) return null;
    return inView
        .reduce(
          (min, position) =>
              position.itemLeadingEdge < min.itemLeadingEdge ? position : min,
        )
        .index;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: itemPositionsListener,
      builder: (context, positions, child) {
        if (positions.isEmpty || messages.isEmpty) {
          return const SizedBox.shrink();
        }

        int? index;
        if (reverse) {
          index = _getTopElementIndex(positions);
        } else {
          index = _getBottomElementIndex(positions);
        }

        if (index == null) return const SizedBox.shrink();
        if (index < 0) return const SizedBox.shrink();

        if (reverse) {
          if (index == messages.length) {
            index = messages.length - index;
          } else {
            index = messages.length - 1 - index;
          }
        }

        final message = messages[index];
        return dateSeparatorBuilder?.call(message.createdAt) ??
            MessageDateTimeSeparator(date: message.createdAt, floating: true);
      },
    );
  }
}
