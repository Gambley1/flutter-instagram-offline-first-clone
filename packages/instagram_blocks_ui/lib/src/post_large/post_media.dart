import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

class PostMedia extends StatelessWidget {
  const PostMedia({
    required this.media,
    required this.withInViewNotifier,
    this.isLiked = false,
    this.likePost,
    this.onPageChanged,
    this.videoPlayerBuilder,
    this.mediaCarouselSettings,
    this.postIndex,
    this.withLikeOverlay = true,
    this.autoHideCurrentIndex = true,
    super.key,
  });

  final List<Media> media;
  final int? postIndex;
  final VoidCallback? likePost;
  final bool isLiked;
  final ValueSetter<int>? onPageChanged;
  final VideoPlayerBuilder? videoPlayerBuilder;
  final MediaCarouselSettings? mediaCarouselSettings;
  final bool withLikeOverlay;
  final bool withInViewNotifier;
  final bool autoHideCurrentIndex;

  MediaCarouselSettings _defaultSettings(
    ValueNotifier<bool> showImagesCountText,
    ValueNotifier<int> currentIndex,
  ) =>
      MediaCarouselSettings.create(
        videoPlayerBuilder: videoPlayerBuilder,
        aspectRatio: media.isReel ? kDefaultVideoAspectRatio : null,
        fit: media.hasVideo ? kDefaultVideoMediaBoxFit : null,
        withInViewNotifier: withInViewNotifier,
        onPageChanged: (index, _) {
          showImagesCountText.value = true;
          currentIndex.value = index;
          onPageChanged?.call(index);
        },
      );

  @override
  Widget build(BuildContext context) {
    final currentIndex = ValueNotifier<int>(0);
    final showImagesCountText = ValueNotifier(!autoHideCurrentIndex);

    final singleImage = media.length == 1;
    final showImagesCount = !singleImage && media.isNotEmpty;

    final carousel = MediaCarousel(
      media: media,
      postIndex: postIndex,
      settings: _defaultSettings(showImagesCountText, currentIndex)
          .merge(other: mediaCarouselSettings),
    );

    return Stack(
      children: [
        if (!withLikeOverlay)
          carousel
        else
          RepaintBoundary(
            child: PoppingIconAnimationOverlay(
              isLiked: isLiked,
              onTap: likePost,
              child: carousel,
            ),
          ),
        if (showImagesCount)
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: AnimatedBuilder(
              animation: Listenable.merge([showImagesCountText, currentIndex]),
              builder: (context, child) {
                if (autoHideCurrentIndex) {
                  if (showImagesCountText.value) {
                    void showImagesCount() {
                      showImagesCountText.value = false;
                    }

                    showImagesCount.debounce(milliseconds: 5000);
                  }
                }

                return RepaintBoundary(
                  child: _CurrentPostImageIndexOfTotal(
                    currentIndex: currentIndex.value + 1,
                    total: media.length,
                    showText: showImagesCountText.value,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CurrentPostImageIndexOfTotal extends StatelessWidget {
  const _CurrentPostImageIndexOfTotal({
    required this.total,
    required this.currentIndex,
    required this.showText,
  });

  final int currentIndex;
  final int total;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final text = '$currentIndex/$total';

    return AnimatedOpacity(
      opacity: showText ? 1 : 0,
      duration: 150.ms,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxs,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: context.customAdaptiveColor(
            light: AppColors.black.withOpacity(.8),
            dark: AppColors.black.withOpacity(.4),
          ),
        ),
        child: Text(
          text,
          style: context.bodyMedium?.apply(color: AppColors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
