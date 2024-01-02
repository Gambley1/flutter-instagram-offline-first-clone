import 'dart:async';

import 'package:flutter/widgets.dart' show VoidCallback;

// A simple class for throttling functions execution
class Throttler {
  Throttler({this.milliseconds = kDefaultDelay});

  final int milliseconds;

  Timer? timer;

  static const kDefaultDelay = 300;

  void run(VoidCallback action) {
    if (timer?.isActive ?? false) return;

    timer?.cancel();
    action();
    timer = Timer(Duration(milliseconds: milliseconds), () {});
  }

  void dispose() {
    timer?.cancel();
  }
}
