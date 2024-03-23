import 'dart:async';

import 'package:flutter/widgets.dart' show VoidCallback;
import 'package:shared/shared.dart';

/// Default debounce time (in milliseconds).
const kDefaultDebounceTime = 150;

/// {@template debouncer}
/// A simple class to debounce functions execution.
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
    _timer = Timer(milliseconds.ms, action);
  }

  /// Disposes the timer.
  void dispose() {
    _timer?.cancel();
  }
}

/// Applies debouncer on the function.
extension DebounceFunction on void Function() {
  /// Function debounce with certain delay.
  void debounce({int milliseconds = kDefaultDebounceTime}) =>
      Debouncer(milliseconds: milliseconds).run(call);
}
