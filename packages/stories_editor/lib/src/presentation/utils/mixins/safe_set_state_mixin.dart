import 'package:flutter/material.dart';

mixin SafeSetStateMixin<T extends StatefulWidget> on State<T> {
  void safeSetState(void Function() fn) {
    if (!mounted) return;
    super.setState(fn);
  }
}
