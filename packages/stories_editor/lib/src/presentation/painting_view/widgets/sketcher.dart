import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:stories_editor/src/domain/models/painting_model.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';

class Sketcher extends CustomPainter {
  final List<PaintingModel> lines;

  Sketcher({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    List<Point>? outlinePoints;

    for (int i = 0; i < lines.length; ++i) {
      switch (lines[i].paintingType) {
        case PaintingType.pen:
          paint = Paint()..color = lines[i].lineColor;

          outlinePoints = getStroke(

              /// coordinates
              lines[i].points,

              /// line width
              size: lines[i].size,

              /// line thin
              thinning: 1,

              /// line smooth
              smoothing: 1,

              /// on complete line
              isComplete: lines[i].isComplete,
              streamline: 1,
              taperEnd: 0,
              taperStart: 0,
              capEnd: true,
              simulatePressure: true,
              capStart: true);
          break;
        case PaintingType.marker:
          paint = Paint()
            ..strokeWidth = 5
            ..color = lines[i].lineColor.withOpacity(0.7)
            ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5)
            ..strokeCap = StrokeCap.square
            ..filterQuality = FilterQuality.high
            ..style = PaintingStyle.fill;
          outlinePoints = getStroke(
            /// coordinates
            lines[i].points,

            /// line width
            size: lines[i].size,

            /// line thin
            thinning: 1,

            /// line smooth
            smoothing: 1,

            /// on complete line
            isComplete: lines[i].isComplete,
          );
          break;
        case PaintingType.neon:
          paint = Paint()
            ..strokeWidth = 5
            ..color = lines[i].lineColor
            ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5)
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round
            ..strokeMiterLimit = 5
            ..filterQuality = FilterQuality.high
            ..style = PaintingStyle.stroke;

          outlinePoints = getStroke(

              /// coordinates
              lines[i].points,

              /// line width
              size: lines[i].size,

              /// line thin
              thinning: -0.1,

              /// line smooth
              smoothing: 1,

              /// on complete line
              isComplete: lines[i].isComplete,
              streamline: lines[i].streamline,
              simulatePressure: lines[i].simulatePressure,
              taperStart: 0,
              taperEnd: 0,
              capStart: true,
              capEnd: true);
          break;
      }

      final path = Path();

      if (outlinePoints.isEmpty) {
        return;
      } else if (outlinePoints.length < 2) {
        /// If the path only has one line, draw a dot.
        path.addOval(Rect.fromCircle(
            center: Offset(outlinePoints[0].x, outlinePoints[0].y), radius: 1));
      } else {
        /// Otherwise, draw a line that connects each point with a curve.
        path.moveTo(outlinePoints[0].x, outlinePoints[0].y);

        for (int i = 1; i < outlinePoints.length - 1; ++i) {
          final p0 = outlinePoints[i];
          final p1 = outlinePoints[i + 1];
          path.quadraticBezierTo(
              p0.x, p0.y, (p0.x + p1.x) / 2, (p0.y + p1.y) / 2);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
