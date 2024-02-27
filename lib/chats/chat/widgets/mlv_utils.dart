import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Gets the index of the top element in the viewport.
int? getTopElementIndex(Iterable<ItemPosition> values) {
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
int? getBottomElementIndex(Iterable<ItemPosition> values) {
  final inView = values.where((position) => position.itemLeadingEdge < 1);
  if (inView.isEmpty) return null;
  return inView
      .reduce(
        (min, position) =>
            position.itemLeadingEdge < min.itemLeadingEdge ? position : min,
      )
      .index;
}
