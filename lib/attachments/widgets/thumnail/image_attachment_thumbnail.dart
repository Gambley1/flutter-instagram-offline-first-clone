// ignore_for_file: comment_references

import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/attachments/widgets/thumnail/thumbnail.dart';
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
    this.fit,
    this.thumbnailSize,
    this.thumbnailResizeType = 'clip',
    this.thumbnailCropType = 'center',
    this.withPlaceholder = true,
    this.withAdaptiveColors = true,
    this.borderRadius,
    this.errorBuilder = _defaultErrorBuilder,
  });

  /// The image attachment to show.
  final Attachment image;

  /// Width of the attachment image thumbnail.
  final double? width;

  /// Height of the attachment image thumbnail.
  final double? height;

  /// Memmory width of the attachment image thumbnail.
  final int? memCacheWidth;

  /// Memmory height of the attachment image thumbnail.
  final int? memCacheHeight;

  /// The border radius of the image.
  final double? borderRadius;

  /// Fit of the attachment image thumbnail.
  final BoxFit? fit;

  /// Size of the attachment image thumbnail.
  final Size? thumbnailSize;

  /// Resize type of the image attachment thumbnail.
  ///
  /// Defaults to [crop]
  final String thumbnailResizeType;

  /// Crop type of the image attachment thumbnail.
  ///
  /// Defaults to [center]
  final String thumbnailCropType;

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
  }) {
    return ThumbnailError(
      error: error,
      stackTrace: stackTrace,
      height: height ?? double.infinity,
      width: width ?? double.infinity,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = image.file;
    if (file != null) {
      return LocalImageAttachment(
        fit: fit,
        file: file,
        width: width,
        height: height,
        withPlaceholder: withPlaceholder,
        errorBuilder: errorBuilder,
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
        withPlaceholder: withPlaceholder,
        withAdaptiveColors: withAdaptiveColors,
        borderRadius: borderRadius,
        errorBuilder: errorBuilder,
      );
    }

    // Return error widget if no image is found.
    return errorBuilder(
      context,
      'Image attachment is not valid',
      StackTrace.current,
      height: height,
      width: width,
    );
  }
}

class LocalImageAttachment extends StatelessWidget {
  const LocalImageAttachment({
    required this.errorBuilder,
    required this.fit,
    this.width,
    this.height,
    this.withPlaceholder = true,
    this.file,
    this.imageFile,
    this.bytes,
    super.key,
  });

  final AttachmentFile? file;
  final Uint8List? bytes;
  final File? imageFile;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool withPlaceholder;
  final ThumbnailErrorBuilder errorBuilder;

  @override
  Widget build(BuildContext context) {
    final bytes = this.bytes ?? imageFile?.readAsBytesSync() ?? file?.bytes;
    if (bytes != null) {
      return CachedMemoryImage(
        uniqueKey: 'app://content/image/${file?.path}/${UidGenerator.v4()}',
        bytes: bytes,
        height: height,
        width: width,
        cacheHeight: height?.toInt(),
        cacheWidth: width?.toInt(),
        fit: fit,
        errorBuilder: errorBuilder,
        placeholder: !withPlaceholder
            ? null
            : ShimmerPlaceholder(
                height: height,
                width: width,
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
    required this.fit,
    required this.memCacheWidth,
    required this.memCacheHeight,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final double? borderRadius;
  final BoxFit? fit;
  final bool withPlaceholder;
  final bool withAdaptiveColors;
  final ThumbnailErrorBuilder errorBuilder;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      cacheKey: url,
      memCacheHeight: memCacheHeight ?? height?.toInt(),
      memCacheWidth: memCacheWidth ?? width?.toInt(),
      imageBuilder: (context, imageProvider) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: borderRadius == null
                ? null
                : BorderRadius.all(Radius.circular(borderRadius!)),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        );
      },
      placeholder: !withPlaceholder
          ? null
          : (context, __) => ShimmerPlaceholder(
                height: height,
                width: width,
                withAdaptiveColors: withAdaptiveColors,
              ),
      errorWidget: (context, url, error) {
        return errorBuilder(
          context,
          error,
          StackTrace.current,
          height: height,
          width: width,
        );
      },
    );
  }
}
