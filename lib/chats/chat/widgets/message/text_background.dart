import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TextBackground extends SingleChildRenderObjectWidget {
  const TextBackground({
    required this.backgroundColor,
    required this.margin,
    required super.child,
    super.key,
  });

  final Color backgroundColor;
  final double margin;

  @override
  BackgroundRender createRenderObject(BuildContext context) {
    return BackgroundRender(
      backgroundColor: backgroundColor,
      margin: margin,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    BackgroundRender renderObject,
  ) {
    renderObject
      ..backgroundColor = backgroundColor
      ..margin = margin;
  }
}

class BackgroundRender extends RenderProxyBoxWithHitTestBehavior {
  BackgroundRender({
    required Color backgroundColor,
    required double margin,
  })  : _backgroundColor = backgroundColor,
        _margin = margin;

  final Path _backgroundPath = Path();
  late Paint _backgroundPaint = _createBackgroundPaint();

  Color _backgroundColor;

  // ignore: avoid_setters_without_getters
  set backgroundColor(Color value) {
    if (_backgroundColor == value) {
      return;
    }
    _backgroundColor = value;
    _backgroundPaint = _createBackgroundPaint();
    markNeedsPaint();
  }

  double _margin;

  // ignore: avoid_setters_without_getters
  set margin(double value) {
    if (_margin == value) {
      return;
    }
    _margin = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    super.performLayout();

    final child = this.child! as RenderParagraph;
    final boxesForSelection = child.getBoxesForSelection(
      TextSelection(
        baseOffset: 0,
        extentOffset: child.text.toPlainText().length,
      ),
    );

    _backgroundPath.reset();
    for (final box in boxesForSelection.reversed) {
      final rect = Rect.fromLTRB(
        box.left - _margin,
        box.top - _margin,
        box.right + _margin,
        box.bottom + _margin,
      );
      _backgroundPath.addRRect(
        RRect.fromRectXY(rect, _cornerRadius, _cornerRadius),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    context.canvas.drawPath(_backgroundPath, _backgroundPaint);
    context.canvas.restore();
    super.paint(context, offset);
  }

  Paint _createBackgroundPaint() {
    return Paint()..color = _backgroundColor;
  }

  static const double _cornerRadius = 16;
}
