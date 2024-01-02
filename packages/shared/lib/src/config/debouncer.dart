import 'dart:async';

import 'package:flutter/widgets.dart' show VoidCallback;

class Debouncer {
  Debouncer({this.milliseconds = 150});

  final int milliseconds;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
