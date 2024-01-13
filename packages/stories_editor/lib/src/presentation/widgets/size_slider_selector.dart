import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';

class SizeSliderWidget extends StatefulWidget {
  const SizeSliderWidget({Key? key}) : super(key: key);

  @override
  State<SizeSliderWidget> createState() => _SizeSliderWidgetState();
}

class _SizeSliderWidgetState extends State<SizeSliderWidget> {
  bool _isChange = false;
  bool _showIndicator = false;
  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = ScreenUtil();

    /// change consumer to class parameter and use this widget for text_size and fingerPaint_size
    return Consumer3<TextEditingNotifier, ControlNotifier, PaintingNotifier>(
      builder: (context, editorNotifier, controlNotifier, paintingNotifier, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            /// custom paint
            AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.only(right: _isChange ? 0 : 15),
                width: _isChange ? 39 : 10,
                height: 300,
                child: CustomPaint(
                  painter: RPSCustomPainter(),
                  size: Size(screenUtil.screenHeight,
                      (screenUtil.screenWidth).toDouble()),
                )),

            /// slider decoration with animations
            AnimatedContainer(
              padding: EdgeInsets.only(left: _isChange ? 1 : 1, right: 2.1),
              duration: const Duration(milliseconds: 300),
              width: _isChange ? 39 : 15,
              height: 300,
              decoration: const BoxDecoration(),
              child: RotatedBox(
                quarterTurns: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 250,
                      height: !_showIndicator ? 2 : 0,
                      decoration: BoxDecoration(
                          color: !_showIndicator
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    Padding(
                      padding: _isChange
                          ? const EdgeInsets.only(top: 2)
                          : const EdgeInsets.all(0),
                      child: Slider(
                        value: controlNotifier.isPainting
                            ? paintingNotifier.lineWidth
                            : editorNotifier.textSize,
                        min: controlNotifier.isPainting ? 5 : 14,
                        max: controlNotifier.isPainting ? 20 : 50,
                        activeColor: Colors.transparent,
                        thumbColor: Colors.white,
                        inactiveColor: Colors.transparent,
                        onChanged: (value) {
                          if (controlNotifier.isPainting) {
                            paintingNotifier.lineWidth = value;
                          } else {
                            editorNotifier.textSize = value;
                          }
                        },
                        onChangeStart: (start) {
                          if (mounted) {
                            setState(() {
                              _isChange = true;
                              _showIndicator = true;
                            });
                          }
                        },
                        onChangeEnd: (end) {
                          if (mounted) {
                            setState(() {
                              _isChange = false;
                              _showIndicator = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// shape slider like instagram
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    Path path0 = Path();
    path0.moveTo(size.width * 0.0980139, size.height * 0.0651296);
    path0.lineTo(size.width * 0.9040833, size.height * 0.0646574);
    path0.lineTo(size.width * 0.5000139, size.height * 0.9537037);
    path0.lineTo(size.width * 0.0980139, size.height * 0.0651296);
    path0.close();

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
