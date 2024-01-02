import 'dart:math' as math;

import 'package:flutter/material.dart';

class TwoRotatingArc extends StatefulWidget {
  const TwoRotatingArc({
    required this.color,
    required this.size,
    super.key,
  });
  final double size;
  final Color color;

  @override
  State<TwoRotatingArc> createState() => _TwoRotatingArcState();
}

class _TwoRotatingArcState extends State<TwoRotatingArc>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final Cubic firstCurve = Curves.easeInQuart;
  final Cubic secondCurve = Curves.easeOutQuart;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(
        reverse: true,
      );
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final strokeWidth = size / 10;
    final color = widget.color;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) => Stack(
        children: <Widget>[
          Visibility(
            visible: _animationController.value <= 0.5,
            child: Transform.rotate(
              angle: Tween<double>(
                begin: 0,
                end: 3 * math.pi / 4,
              )
                  .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        0,
                        0.5,
                        curve: firstCurve,
                      ),
                    ),
                  )
                  .value,
              child: Arc.draw(
                color: color,
                size: size,
                strokeWidth: strokeWidth,
                startAngle: -math.pi / 2,
                // endAngle: math.pi / (size * size),
                endAngle: Tween<double>(
                  begin: math.pi / (size * size),
                  end: -math.pi / 2,
                )
                    .animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0,
                          0.5,
                          curve: firstCurve,
                        ),
                      ),
                    )
                    .value,
              ),
            ),
          ),
          Visibility(
            visible: _animationController.value >= 0.5,
            child: Transform.rotate(
              angle: Tween<double>(
                begin: math.pi / 4,
                end: math.pi,
              )
                  .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        0.5,
                        1,
                        curve: secondCurve,
                      ),
                    ),
                  )
                  .value,
              child: Arc.draw(
                color: color,
                size: size,
                strokeWidth: strokeWidth,
                startAngle: -math.pi / 2,
                // endAngle: math.pi / (size * size),
                endAngle: Tween<double>(
                  begin: math.pi / 2,
                  end: math.pi / (size * size),
                )
                    .animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.5,
                          1,
                          curve: secondCurve,
                        ),
                      ),
                    )
                    .value,
              ),
            ),
          ),

          ///
          ///second one
          ///
          ///
          Visibility(
            visible: _animationController.value <= 0.5,
            child: Transform.rotate(
              angle: Tween<double>(begin: -math.pi, end: -math.pi / 4)
                  .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(0, 0.5, curve: firstCurve),
                    ),
                  )
                  .value,
              child: Arc.draw(
                color: color,
                size: size,
                strokeWidth: strokeWidth,
                startAngle: -math.pi / 2,
                // endAngle: math.pi / (size * size),
                endAngle: Tween<double>(
                  begin: math.pi / (size * size),
                  end: -math.pi / 2,
                )
                    .animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0,
                          0.5,
                          curve: firstCurve,
                        ),
                      ),
                    )
                    .value,
              ),
            ),
          ),
          Visibility(
            visible: _animationController.value >= 0.5,
            child: Transform.rotate(
              angle: Tween<double>(
                begin: -3 * math.pi / 4,
                end: 0,
              )
                  .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        0.5,
                        1,
                        curve: secondCurve,
                      ),
                    ),
                  )
                  .value,
              child: Arc.draw(
                color: color,
                size: size,
                strokeWidth: strokeWidth,
                startAngle: -math.pi / 2,
                // endAngle: math.pi / (size * size),
                endAngle: Tween<double>(
                  begin: math.pi / 2,
                  end: math.pi / (size * size),
                )
                    .animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.5,
                          1,
                          curve: secondCurve,
                        ),
                      ),
                    )
                    .value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class Arc extends CustomPainter {
  Arc._(
    this._color,
    this._strokeWidth,
    this._startAngle,
    this._sweepAngle,
  );

  final Color _color;
  final double _strokeWidth;
  final double _sweepAngle;
  final double _startAngle;

  static Widget draw({
    required Color color,
    required double size,
    required double strokeWidth,
    required double startAngle,
    required double endAngle,
  }) =>
      SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: Arc._(
            color,
            strokeWidth,
            startAngle,
            endAngle,
          ),
        ),
      );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.height / 2,
    );

    const useCenter = false;
    final paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _strokeWidth;

    canvas.drawArc(rect, _startAngle, _sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
