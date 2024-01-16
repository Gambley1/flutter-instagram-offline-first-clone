import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

typedef ThumbnailErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
);

/// {@template thumbnailError}
/// A widget that shows an error state when a thumbnail fails to load.
/// {@endtemplate}
class ThumbnailError extends StatelessWidget {
  /// {@macro thumbnailError}
  const ThumbnailError({
    required this.error,
    super.key,
    this.stackTrace,
    this.width,
    this.height,
    this.fit,
  });

  /// The width of the thumbnail.
  final double? width;

  /// The height of the thumbnail.
  final double? height;

  /// How to inscribe the thumbnail into the space allocated during layout.
  final BoxFit? fit;

  /// The error that triggered this error widget.
  final Object error;

  /// The stack trace of the error that triggered this error widget.
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Assets.images.placeholder.image(
      width: width,
      height: height,
      fit: fit,
    );
  }
}
