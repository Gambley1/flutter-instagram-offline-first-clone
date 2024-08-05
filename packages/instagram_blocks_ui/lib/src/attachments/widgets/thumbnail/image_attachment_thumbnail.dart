// ignore_for_file: comment_references

import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

/// {@template imageAttachmentThumbnail}
/// Widget for building image attachment thumbnail.
///
/// This widget is used when the [Attachment.type] is [AttachmentType.image].
/// {@endtemplate}
class ImageAttachmentThumbnail extends StatelessWidget {
  /// {@macro imageAttachmentThumbnail}
  const ImageAttachmentThumbnail({
    required this.image,
    super.key,
    this.width,
    this.height,
    this.memCacheHeight,
    this.memCacheWidth,
    this.resizeHeight,
    this.resizeWidth,
    this.fit,
    this.filterQuality = FilterQuality.low,
    this.withPlaceholder = true,
    this.withAdaptiveColors = true,
    this.borderRadius,
    this.border,
    this.errorBuilder = _defaultErrorBuilder,
  });

  /// The image attachment to show.
  final Attachment image;

  /// Width of the attachment image thumbnail.
  final double? width;

  /// Height of the attachment image thumbnail.
  final double? height;

  /// Memory width of the attachment image thumbnail.
  final int? memCacheWidth;

  /// Memory height of the attachment image thumbnail.
  final int? memCacheHeight;

  /// Resize width of the attachment image thumbnail.
  final int? resizeWidth;

  /// Resize height of the attachment image thumbnail.
  final int? resizeHeight;

  /// The border radius of the image.
  final double? borderRadius;

  /// The border of the container that wraps an image.
  final BoxBorder? border;

  /// Fit of the attachment image thumbnail.
  final BoxFit? fit;

  /// The quality of the image. Default is low.
  final FilterQuality filterQuality;

  /// Whether to show a default shimmer placeholder when image is loading.
  final bool withPlaceholder;

  /// Whether the shimmer placeholder should use adaptive colors.
  final bool withAdaptiveColors;

  /// Builder used when the thumbnail fails to load.
  final ThumbnailErrorBuilder errorBuilder;

  // Default error builder for image attachment thumbnail.
  static Widget _defaultErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace, {
    double? height,
    double? width,
    int? resizeHeight,
    int? resizeWidth,
    double? borderRadius,
  }) {
    return ThumbnailError(
      error: error,
      stackTrace: stackTrace,
      height: height ?? double.infinity,
      width: width ?? double.infinity,
      resizeWidth: resizeWidth,
      resizeHeight: resizeHeight,
      borderRadius: borderRadius,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = image.file;
    final width = image.originalWidth?.toDouble() ?? this.width;
    final height = image.originalHeight?.toDouble() ?? this.height;

    if (file != null) {
      return LocalImageAttachment(
        fit: fit,
        file: file,
        width: width,
        height: height,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        borderRadius: borderRadius,
        withPlaceholder: withPlaceholder,
        withAdaptiveColors: withAdaptiveColors,
        errorBuilder: errorBuilder,
        filterQuality: filterQuality,
      );
    }

    final imageUrl = image.thumbUrl ?? image.imageUrl ?? image.assetUrl;
    if (imageUrl != null) {
      return NetworkImageAttachment(
        url: imageUrl,
        fit: fit,
        width: width,
        height: height,
        memCacheHeight: memCacheHeight,
        memCacheWidth: memCacheWidth,
        resizeHeight: resizeHeight,
        resizeWidth: resizeWidth,
        withPlaceholder: withPlaceholder,
        withAdaptiveColors: withAdaptiveColors,
        borderRadius: borderRadius,
        border: border,
        errorBuilder: errorBuilder,
        filterQuality: filterQuality,
      );
    }

    // Return error widget if no image is found.
    return errorBuilder(
      context,
      'Image attachment is not valid',
      StackTrace.current,
      width: width,
      height: height,
      resizeWidth: resizeWidth,
      resizeHeight: resizeHeight,
      borderRadius: borderRadius,
    );
  }
}

class LocalImageAttachment extends StatelessWidget {
  const LocalImageAttachment({
    required this.errorBuilder,
    required this.fit,
    this.width,
    this.height,
    this.cacheWidth,
    this.cacheHeight,
    this.borderRadius,
    this.withPlaceholder = true,
    this.file,
    this.filterQuality = FilterQuality.low,
    this.imageFile,
    this.bytes,
    this.withAdaptiveColors = true,
    super.key,
  });

  final AttachmentFile? file;
  final Uint8List? bytes;
  final File? imageFile;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;
  final double? borderRadius;
  final BoxFit? fit;
  final FilterQuality filterQuality;
  final bool withPlaceholder;
  final bool withAdaptiveColors;
  final ThumbnailErrorBuilder errorBuilder;

  @override
  Widget build(BuildContext context) {
    final bytes = this.bytes ?? imageFile?.readAsBytesSync() ?? file?.bytes;
    if (bytes != null) {
      return CachedMemoryImage(
        uniqueKey: 'app://content/image/${file?.path}/${uuid.v4()}',
        fit: fit,
        bytes: bytes,
        height: height,
        width: width,
        cacheHeight: cacheHeight,
        cacheWidth: cacheWidth,
        errorBuilder: errorBuilder,
        filterQuality: filterQuality,
        placeholder: !withPlaceholder
            ? null
            : ShimmerPlaceholder(
                height: height,
                width: width,
                withAdaptiveColors: withAdaptiveColors,
                borderRadius: borderRadius,
              ),
      );
    }

    final path = imageFile?.path ?? file?.path;
    if (path != null) {
      return Image.file(
        File(path),
        width: width,
        height: height,
        cacheHeight: height?.toInt(),
        cacheWidth: width?.toInt(),
        fit: fit,
      );
    }

    // Return error widget if no image is found.
    return errorBuilder(
      context,
      'Image attachment is not valid',
      StackTrace.current,
      height: height,
      width: width,
      borderRadius: borderRadius,
    );
  }
}

class NetworkImageAttachment extends StatelessWidget {
  const NetworkImageAttachment({
    required this.url,
    required this.errorBuilder,
    required this.withAdaptiveColors,
    required this.withPlaceholder,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.border,
    required this.fit,
    required this.memCacheWidth,
    required this.memCacheHeight,
    required this.resizeHeight,
    required this.resizeWidth,
    required this.filterQuality,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? resizeHeight;
  final int? resizeWidth;
  final double? borderRadius;
  final BoxBorder? border;
  final BoxFit? fit;
  final FilterQuality filterQuality;
  final bool withPlaceholder;
  final bool withAdaptiveColors;
  final ThumbnailErrorBuilder errorBuilder;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      cacheKey: url,
      memCacheHeight: memCacheHeight,
      memCacheWidth: memCacheWidth,
      imageBuilder: (context, imageProvider) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            border: border,
            borderRadius: borderRadius == null
                ? null
                : BorderRadius.all(Radius.circular(borderRadius!)),
            image: DecorationImage(
              image: ResizeImage.resizeIfNeeded(
                resizeWidth,
                resizeHeight,
                imageProvider,
              ),
              fit: fit,
              filterQuality: filterQuality,
            ),
          ),
        );
      },
      placeholder: !withPlaceholder
          ? null
          : (context, __) => ShimmerPlaceholder(
                width: width,
                height: height,
                withAdaptiveColors: withAdaptiveColors,
                borderRadius: borderRadius,
              ),
      errorWidget: (context, url, error) {
        return errorBuilder(
          context,
          error,
          StackTrace.current,
          height: height,
          width: width,
          resizeWidth: resizeWidth,
          resizeHeight: resizeHeight,
          borderRadius: borderRadius,
        );
      },
    );
  }
}
