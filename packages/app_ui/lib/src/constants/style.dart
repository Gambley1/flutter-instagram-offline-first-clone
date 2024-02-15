import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Outlined border with default border radius. It is used to avoid
/// boilerplate code.
OutlineInputBorder outlinedBorder({
  double borderRadius = defaultBorderRadius,
  BorderSide? borderSide,
}) =>
    OutlineInputBorder(
      borderSide: borderSide ??  BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    );
