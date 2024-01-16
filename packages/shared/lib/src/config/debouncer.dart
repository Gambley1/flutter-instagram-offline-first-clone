import 'dart:async';

import 'package:flutter/widgets.dart' show VoidCallback;

/// Default debounce time (in milliseconds).
const kDefaultDebounceTime = 150;

/// {@template debouncer}
/// A simple class for debouncing functions execution.
/// {@endtemplate}
class Debouncer {
  /// {@macro debouncer}
  Debouncer({this.milliseconds = kDefaultDebounceTime});

  /// The delay in milliseconds.
  final int milliseconds;

  Timer? _timer;

  /// Runs the [action] after [milliseconds] delay.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Disposes the timer.
  void dispose() {
    _timer?.cancel();
  }
}
