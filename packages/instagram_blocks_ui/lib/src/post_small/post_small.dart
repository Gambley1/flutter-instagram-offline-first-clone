import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/attachments/index.dart';
import 'package:shared/shared.dart';

typedef ImageThumbnailBuilder = Widget Function(
  BuildContext context,
  String url,
);

class PostSmall extends StatelessWidget {
  PostSmall({
    required this.pinned,
    required this.multiMedia,
    required this.mediaUrl,
    this.isReel,
    this.imageThumbnailBuilder,
    super.key,
  });

  final String mediaUrl;
  final bool? isReel;
  final bool pinned;
  final bool multiMedia;
  final ImageThumbnailBuilder? imageThumbnailBuilder;

  late final _showPinned = pinned && multiMedia || pinned && !multiMedia;

  late final _showHasMultiplePhotos = !pinned && multiMedia;

  late final _showVideoIcon = !_showPinned && (isReel ?? false);

  @override
  Widget build(BuildContext context) {
    return _PostThumbnailImage(
      mediaUrl: mediaUrl,
      showPinned: _showPinned,
      showHasMultiplePhotos: _showHasMultiplePhotos,
      showVideoIcon: _showVideoIcon,
      imageThumbnailBuilder: imageThumbnailBuilder,
    );
  }
}

class _PostThumbnailImage extends StatelessWidget {
  const _PostThumbnailImage({
    required this.mediaUrl,
    required this.showPinned,
    required this.showHasMultiplePhotos,
    required this.showVideoIcon,
    required this.imageThumbnailBuilder,
  });

  final String mediaUrl;
  final bool showPinned;
  final bool showHasMultiplePhotos;
  final bool showVideoIcon;
  final ImageThumbnailBuilder? imageThumbnailBuilder;

  @override
  Widget build(BuildContext context) {
    final thumbnailImage = imageThumbnailBuilder?.call(context, mediaUrl) ??
        ImageAttachmentThumbnail(
          image: Attachment(imageUrl: mediaUrl),
          memCacheHeight: 225,
          memCacheWidth: 225,
          fit: BoxFit.cover,
        );

    final icon = Icon(
      showPinned ? Icons.push_pin : Icons.layers,
      size: AppSize.iconSizeMedium,
      color: Colors.white,
      shadows: const [
        Shadow(
          blurRadius: 2,
        ),
      ],
    );

    final rotatedOrNotIcon = showPinned
        ? Transform.rotate(
            angle: 0.75,
            child: icon,
          )
        : icon;

    final pinnedOrMultiplePhotosIcon = Positioned(
      top: 4,
      right: 4,
      child: rotatedOrNotIcon,
    );

    late final videoReelIcon = Positioned(
      top: 4,
      right: 6,
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Assets.icons.instagramReel.svg(
          height: 22,
          width: 22,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );

    if (showPinned || showHasMultiplePhotos || showVideoIcon) {
      return Stack(
        children: [
          thumbnailImage,
          if (showVideoIcon) videoReelIcon else pinnedOrMultiplePhotosIcon,
        ],
      );
    } else {
      return thumbnailImage;
    }
  }
}
