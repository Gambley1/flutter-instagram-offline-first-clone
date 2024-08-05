import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

typedef ThumbnailErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace? stackTrace, {
  double? height,
  double? width,
  int? resizeWidth,
  int? resizeHeight,
  double? borderRadius,
});

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
    this.resizeWidth,
    this.resizeHeight,
    this.borderRadius,
    this.fit,
  });

  /// The width of the thumbnail.
  final double? width;

  /// The height of the thumbnail.
  final double? height;

  /// The resize width of the thumbnail.
  final int? resizeWidth;

  /// The resize height of the thumbnail.
  final int? resizeHeight;

  /// The border radius of the thumbnail.
  final double? borderRadius;

  /// How to inscribe the thumbnail into the space allocated during layout.
  final BoxFit? fit;

  /// The error that triggered this error widget.
  final Object error;

  /// The stack trace of the error that triggered this error widget.
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius == null
              ? null
              : BorderRadius.all(Radius.circular(borderRadius!)),
          image: DecorationImage(
            fit: fit,
            filterQuality: FilterQuality.high,
            image: ResizeImage.resizeIfNeeded(
              resizeWidth,
              resizeHeight,
              Assets.images.placeholder.provider(),
            ),
          ),
        ),
      ),
    );
  }
}
