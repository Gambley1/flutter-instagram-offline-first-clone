// ignore_for_file: one_member_abstracts

import 'package:flutter/rendering.dart';

class BubbleRenderBox extends RenderProxyBoxWithHitTestBehavior {
  BubbleRenderBox({
    required Color color,
    required BorderPathProvider borderPathProvider,
  })  : _color = color,
        _borderPathProvider = borderPathProvider,
        super(behavior: HitTestBehavior.opaque) {
    _createBorderPaint();
  }

  Paint? borderPaint;

  BorderPathProvider get borderPathProvider => _borderPathProvider;
  BorderPathProvider _borderPathProvider;

  set borderPathProvider(BorderPathProvider value) {
    if (value == _borderPathProvider) {
      return;
    }
    _borderPathProvider = value;
    _createBorderPaint();
    markNeedsPaint();
  }

  Color get color => _color;
  Color _color;

  set color(Color value) {
    if (value == _color) {
      return;
    }
    _color = value;
    _createBorderPaint();
    markNeedsPaint();
  }

  void _createBorderPaint() {
    borderPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _color;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }

    final paint = borderPaint;

    if (paint != null) {
      context.canvas
        ..save()
        ..translate(offset.dx, offset.dy)
        ..drawPath(_borderPathProvider.getPath(size), paint)
        ..restore();
    }
  }
}

abstract class BorderPathProvider {
  Path getPath(Size size);
}
