import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Useful extensions on [BoxConstraints].
extension ConstraintsX on BoxConstraints {
  /// Returns new box constraints that tightens the max width and max height
  /// to the given [size].
  BoxConstraints tightenMaxSize(Size? size) {
    if (size == null) return this;
    return copyWith(
      maxWidth: clampDouble(size.width, minWidth, maxWidth),
      maxHeight: clampDouble(size.height, minHeight, maxHeight),
    );
  }
}
