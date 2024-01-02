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
    required this.hasMultiplePhotos,
    required this.mediaUrl,
    this.onDeletePost,
    this.tappableColor,
    super.key,
  });

  final bool isOwner;

  final PostTapCallback onTap;

  final DeletePostCallback? onDeletePost;

  final Color? tappableColor;

  final String mediaUrl;

  final bool pinned;

  final bool hasMultiplePhotos;

  late final _showPinned =
      pinned && hasMultiplePhotos || pinned && !hasMultiplePhotos;

  late final _showHasMultiplePhotos = !pinned && hasMultiplePhotos;

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
              if (onDeletePost == null) return;
              onDeletePost?.call();
            },
      onTap: onTap,
      child: _PostThumbnailImage(
        mediaUrl,
        showPinned: _showPinned,
        showHasMultiplePhotos: _showHasMultiplePhotos,
      ),
    );
  }
}

class _PostThumbnailImage extends StatelessWidget {
  const _PostThumbnailImage(
    this.mediaUrl, {
    required this.showPinned,
    required this.showHasMultiplePhotos,
  });

  final String mediaUrl;

  final bool showPinned;

  final bool showHasMultiplePhotos;

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
      size: 26,
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

    if (showPinned || showHasMultiplePhotos) {
      return Stack(
        children: [
          thumbnailImage,
          pinnedOrMultiplePhotosIcon,
        ],
      );
    } else {
      return thumbnailImage;
    }
  }
}
