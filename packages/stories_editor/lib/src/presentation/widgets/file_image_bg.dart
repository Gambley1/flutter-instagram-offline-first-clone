import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stories_editor/src/presentation/utils/color_detection.dart';
import 'package:stories_editor/src/presentation/utils/mixins/safe_set_state_mixin.dart';

class FileImageBG extends StatefulWidget {
  final File? filePath;
  final void Function(Color color1, Color color2) generatedGradient;
  const FileImageBG({
    super.key,
    required this.filePath,
    required this.generatedGradient,
  });

  @override
  State<FileImageBG> createState() => _FileImageBGState();
}

class _FileImageBGState extends State<FileImageBG> with SafeSetStateMixin {
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();

  GlobalKey? currentKey;

  final StreamController<Color> stateController = StreamController<Color>();
  var color1 = Colors.grey[350]!;
  var color2 = Colors.grey[350]!;

  Timer? _timer;

  @override
  void initState() {
    currentKey = paintKey;
    if (mounted) {
      _timer =
          Timer.periodic(const Duration(milliseconds: 500), _periodicFunction);
    }
    super.initState();
  }

  Future<void> _periodicFunction(Timer callback) async {
    if (imageKey.currentState?.context.size?.height == 0.0) {
    } else {
      var cd1 = await ColorDetection(
        currentKey: currentKey,
        paintKey: paintKey,
        stateController: stateController,
      ).searchPixel(
          Offset(imageKey.currentState!.context.size!.width / 2, 480));
      var cd12 = await ColorDetection(
        currentKey: currentKey,
        paintKey: paintKey,
        stateController: stateController,
      ).searchPixel(
          Offset(imageKey.currentState!.context.size!.width / 2.03, 530));
      color1 = cd1;
      color2 = cd12;
      safeSetState(() {});
      widget.generatedGradient(color1, color2);
      callback.cancel();
      stateController.close();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    stateController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = ScreenUtil();
    return SizedBox(
      height: screenUtil.screenHeight,
      width: screenUtil.screenWidth,
      child: RepaintBoundary(
        key: paintKey,
        child: Center(
          child: Image.file(
            File(widget.filePath!.path),
            key: imageKey,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
