import 'dart:async';

import 'package:flutter/widgets.dart' show VoidCallback;

/// {@template throttles}
/// A simple class for throttling functions execution
/// {@endtemplate}
class Throttler {
  /// {@macro throttler}
  Throttler({this.milliseconds = _kDefaultDelay});

  static const _kDefaultDelay = 300;

  /// The delay in milliseconds.
  final int milliseconds;

  /// The timer of the throttler.
  Timer? timer;

  /// Runs the [action] after [milliseconds] delay.
  void run(VoidCallback action) {
    if (timer?.isActive ?? false) return;

    timer?.cancel();
    action();
    timer = Timer(Duration(milliseconds: milliseconds), () {});
  }

  /// Disposes the timer.
  void dispose() {
    timer?.cancel();
  }
}
