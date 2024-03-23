import 'dart:async';

import 'package:flutter/widgets.dart' show VoidCallback;
import 'package:shared/shared.dart';

/// Default duration of throttler.
const kDefaultThrottlerDuration = 300;

/// {@template throttler}
/// A simple class for throttling functions execution
/// {@endtemplate}
class Throttler {
  /// {@macro throttler}
  Throttler({this.milliseconds = kDefaultThrottlerDuration});

  /// The delay in milliseconds.
  final int? milliseconds;

  /// The timer of the throttler.
  Timer? timer;

  /// Runs the [action] after [milliseconds] delay.
  void run(VoidCallback action) {
    if (timer?.isActive ?? false) return;

    timer?.cancel();
    action();
    timer = Timer(milliseconds?.ms ?? kDefaultThrottlerDuration.ms, () {});
  }

  /// Disposes the timer.
  void dispose() {
    timer?.cancel();
  }
}

/// Applies throttler on the function.
extension ThrottleFunction on void Function() {
  /// Throttles function with certain delay.
  void throttle({int milliseconds = kDefaultThrottlerDuration}) =>
      Throttler(milliseconds: milliseconds).run(call);
}
