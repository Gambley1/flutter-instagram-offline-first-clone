import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/media_widget.dart';

class MessageContent extends MultiChildRenderObjectWidget {
  const MessageContent({
    super.key,
    super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => _ContentRenderBox();
}

class _ContentRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ParentData) {
      child.parentData = _ParentData();
    }
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    final width = _computeWidth(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );
    size = Size(width, constraints.minHeight);
    _layout(constraints.copyWith(maxWidth: width));
  }

  void _layout(BoxConstraints constraints) {
    var child = firstChild;

    var offset = 0.0;

    while (child != null) {
      final childParentData = child.parentData! as _ParentData;

      final childSize = ChildLayoutHelper.layoutChild(child, constraints);

      childParentData.offset = Offset(0, offset);
      offset = offset + childSize.height;
      child = childParentData.nextSibling;
    }

    size = Size(constraints.maxWidth, offset);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  double _computeWidth({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
  }) {
    var width = constraints.minWidth;

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _ParentData;

      final childSize = layoutChild(child, constraints);

      if (child is MediaRender) {
        return childSize.width;
      }

      width = math.max(width, childSize.width);
      child = childParentData.nextSibling;
    }

    return width;
  }
}

class _ParentData extends ContainerBoxParentData<RenderBox> {}
