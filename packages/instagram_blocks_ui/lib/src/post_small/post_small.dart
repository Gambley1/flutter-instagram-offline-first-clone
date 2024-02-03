// ignore_for_file: deprecated_member_use

import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/widgets/confirm_deletion.dart';

typedef PostTapCallback = void Function();

typedef DeletePostCallback = void Function();

class PostSmall extends StatelessWidget {
  PostSmall({
    required this.isOwner,
    required this.onTap,
    required this.pinned,
    required this.multiMedia,
    required this.mediaUrl,
    this.isReel,
    this.onPostDelete,
    this.tappableColor,
    super.key,
  });

  final bool isOwner;
  final PostTapCallback onTap;
  final DeletePostCallback? onPostDelete;
  final Color? tappableColor;
  final String mediaUrl;
  final bool? isReel;
  final bool pinned;
  final bool multiMedia;

  late final _showPinned = pinned && multiMedia || pinned && !multiMedia;

  late final _showHasMultiplePhotos = !pinned && multiMedia;

  late final _showVideoIcon = !_showPinned && (isReel ?? false);

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onLongPress: !isOwner
          ? null
          : () async {
              final confirmed = await context.showConfirmDeletion(
                title: 'Delete this post?',
              );
              if (!confirmed) return;
              if (onPostDelete == null) return;
              onPostDelete?.call();
            },
      onTap: onTap,
      child: _PostThumbnailImage(
        mediaUrl,
        showPinned: _showPinned,
        showHasMultiplePhotos: _showHasMultiplePhotos,
        showVideoIcon: _showVideoIcon,
      ),
    );
  }
}

class _PostThumbnailImage extends StatelessWidget {
  const _PostThumbnailImage(
    this.mediaUrl, {
    required this.showPinned,
    required this.showHasMultiplePhotos,
    required this.showVideoIcon,
  });

  final String mediaUrl;
  final bool showPinned;
  final bool showHasMultiplePhotos;
  final bool showVideoIcon;

  @override
  Widget build(BuildContext context) {
    final thumbnailImage = mediaUrl.isEmpty
        ? const SizedBox.shrink()
        : CachedNetworkImage(
            imageUrl: mediaUrl,
            cacheKey: '${mediaUrl}_thumbnail',
            memCacheHeight: 225,
            memCacheWidth: 225,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
          color: Colors.white,
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
