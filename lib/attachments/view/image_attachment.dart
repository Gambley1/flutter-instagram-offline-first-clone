// ignore_for_file: comment_references

import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/attachments/widgets/thumnail/thumbnail.dart';
import 'package:shared/shared.dart';

/// {@template image_attachment}
/// Shows an image attachment.
/// {@endtemplate}
class ImageAttachment extends StatelessWidget {
  /// {@macro image_attachment}
  const ImageAttachment({
    required this.message,
    required this.image,
    super.key,
    this.shape,
    this.constraints = const BoxConstraints(),
    this.imageThumbnailSize = const Size(400, 400),
    this.imageThumbnailResizeType = 'clip',
    this.imageThumbnailCropType = 'center',
  });

  /// The [Message] that the image is attached to.
  final Message message;

  /// The [Attachment] object containing the image information.
  final Attachment image;

  /// The shape of the attachment.
  ///
  /// Defaults to [RoundedRectangleBorder] with a radius of 14.
  final ShapeBorder? shape;

  /// The constraints to use when displaying the image.
  final BoxConstraints constraints;

  /// Size of the attachment image thumbnail.
  final Size imageThumbnailSize;

  /// Resize type of the image attachment thumbnail.
  ///
  /// Defaults to [crop]
  final String /*clip|crop|scale|fill*/ imageThumbnailResizeType;

  /// Crop type of the image attachment thumbnail.
  ///
  /// Defaults to [center]
  final String /*center|top|bottom|left|right*/ imageThumbnailCropType;

  @override
  Widget build(BuildContext context) {
    BoxFit? fit;
    final imageSize = image.originalSize;

    // If attachment size is available, we will tighten the constraints max
    // size to the attachment size.
    var constraints = this.constraints;
    if (imageSize != null) {
      constraints = constraints.tightenMaxSize(imageSize);
    } else {
      // For backward compatibility, we will fill the available space if the
      // attachment size is not available.
      fit = BoxFit.cover;
    }

    final shape = this.shape ??
        RoundedRectangleBorder(
          side: const BorderSide(
            color: Color(0xff1c1e22),
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(14),
        );

    return Container(
      constraints: constraints,
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(shape: shape),
      child: AspectRatio(
        aspectRatio: imageSize?.aspectRatio ?? 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ImageAttachmentThumbnail(
              image: image,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              thumbnailSize: imageThumbnailSize,
              thumbnailResizeType: imageThumbnailResizeType,
              thumbnailCropType: imageThumbnailCropType,
            ),
            // Padding(
            //   padding: const EdgeInsets.all(AppSpacing.sm),
            //   child: StreamAttachmentUploadStateBuilder(
            //     message: message,
            //     attachment: image,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
