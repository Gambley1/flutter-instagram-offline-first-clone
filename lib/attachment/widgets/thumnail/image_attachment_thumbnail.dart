// ignore_for_file: comment_references

import 'dart:io' show File;
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/attachment/widgets/thumnail/thumbnail.dart';
import 'package:shared/shared.dart';
import 'package:shimmer/shimmer.dart';

/// Transparent image data.
final kTransparentImage = Uint8List.fromList(
  <int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
  ],
);

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
    this.fit,
    this.thumbnailSize,
    this.thumbnailResizeType = 'clip',
    this.thumbnailCropType = 'center',
    this.borderRadius,
    this.errorBuilder = _defaultErrorBuilder,
  });

  /// The image attachment to show.
  final Attachment image;

  /// Width of the attachment image thumbnail.
  final double? width;

  /// Height of the attachment image thumbnail.
  final double? height;

  /// The border radius of the image.
  final double? borderRadius;

  /// Fit of the attachment image thumbnail.
  final BoxFit? fit;

  /// Size of the attachment image thumbnail.
  final Size? thumbnailSize;

  /// Resize type of the image attachment thumbnail.
  ///
  /// Defaults to [crop]
  final String /*clip|crop|scale|fill*/ thumbnailResizeType;

  /// Crop type of the image attachment thumbnail.
  ///
  /// Defaults to [center]
  final String /*center|top|bottom|left|right*/ thumbnailCropType;

  /// Builder used when the thumbnail fails to load.
  final ThumbnailErrorBuilder errorBuilder;

  // Default error builder for image attachment thumbnail.
  static Widget _defaultErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return ThumbnailError(
      error: error,
      stackTrace: stackTrace,
      height: double.infinity,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = image.file;
    if (file != null) {
      return LocalImageAttachment(
        file: file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }

    var imageUrl = image.thumbUrl ?? image.imageUrl ?? image.assetUrl;
    if (imageUrl != null) {
      final thumbnailSize = this.thumbnailSize;
      if (thumbnailSize != null) {
        imageUrl = imageUrl.getResizedImageUrl(
          width: thumbnailSize.width,
          height: thumbnailSize.height,
          resize: thumbnailResizeType,
          crop: thumbnailCropType,
        );
      }

      return NetworkImageAttachment(
        url: imageUrl,
        width: width,
        height: height,
        borderRadius: borderRadius,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }

    // Return error widget if no image is found.
    return errorBuilder(
      context,
      'Image attachment is not valid',
      StackTrace.current,
    );
  }
}

class LocalImageAttachment extends StatelessWidget {
  const LocalImageAttachment({
    required this.errorBuilder,
    this.file,
    this.bytes,
    this.imageFile,
    super.key,
    this.width,
    this.height,
    this.fit,
  });

  final AttachmentFile? file;
  final Uint8List? bytes;
  final File? imageFile;
  final double? width;
  final double? height;
  final BoxFit? fit;
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
        placeholder: Builder(
          builder: (context) {
            final image = Assets.images.placeholder.image(
              width: width,
              height: height,
              fit: BoxFit.cover,
            );

            return Shimmer.fromColors(
              baseColor: context.customReversedAdaptiveColor(
                dark: const Color(0xff2d2f2f),
                light: Colors.white.withOpacity(.4),
              ),
              highlightColor: context.customReversedAdaptiveColor(
                dark: const Color(0xff13151b),
                light: const Color.fromARGB(255, 181, 190, 226),
              ),
              child: image,
            );
          },
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
    );
  }
}

class NetworkImageAttachment extends StatelessWidget {
  const NetworkImageAttachment({
    required this.url,
    required this.errorBuilder,
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.fit,
  });

  final String url;
  final double? width;
  final double? height;
  final double? borderRadius;
  final BoxFit? fit;
  final ThumbnailErrorBuilder errorBuilder;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      memCacheHeight: 132,
      memCacheWidth: 132,
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
      placeholder: (context, __) {
        final image = Assets.images.placeholder.image(
          width: width,
          height: height,
          fit: BoxFit.cover,
        );

        return Shimmer.fromColors(
          baseColor: context.customReversedAdaptiveColor(
            dark: const Color(0xff2d2f2f),
            light: Colors.white.withOpacity(.4),
          ),
          highlightColor: context.customReversedAdaptiveColor(
            dark: const Color(0xff13151b),
            light: const Color.fromARGB(255, 181, 190, 226),
          ),
          child: image,
        );
      },
      errorWidget: (context, url, error) {
        return errorBuilder(
          context,
          error,
          StackTrace.current,
        );
      },
    );
  }
}
