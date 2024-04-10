import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

class PostMedia extends StatefulWidget {
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

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {
  MediaCarouselSettings _defaultSettings(
    ValueNotifier<bool> showImagesCountText,
    ValueNotifier<int> currentIndex,
  ) =>
      MediaCarouselSettings.create(
        videoPlayerBuilder: widget.videoPlayerBuilder,
        aspectRatio: widget.media.isReel ? kDefaultVideoAspectRatio : null,
        fit: widget.media.hasVideo ? kDefaultVideoMediaBoxFit : null,
        withInViewNotifier: widget.withInViewNotifier,
        onPageChanged: (index, _) {
          showImagesCountText.value = true;
          currentIndex.value = index;
          widget.onPageChanged?.call(index);
        },
      );

  late Debouncer _debouncer;
  late ValueNotifier<int> _currentIndex;
  late ValueNotifier<bool> _showImagesCountText;

  bool get singleImage => widget.media.length == 1;
  bool get showImagesCount => !singleImage && widget.media.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(milliseconds: 5000);
    _currentIndex = ValueNotifier(0);
    _showImagesCountText = ValueNotifier(!widget.autoHideCurrentIndex);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _currentIndex.dispose();
    _showImagesCountText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carousel = MediaCarousel(
      media: widget.media,
      postIndex: widget.postIndex,
      settings: _defaultSettings(_showImagesCountText, _currentIndex)
          .merge(other: widget.mediaCarouselSettings),
    );

    return Stack(
      children: [
        if (!widget.withLikeOverlay)
          carousel
        else
          RepaintBoundary(
            child: PoppingIconAnimationOverlay(
              isLiked: widget.isLiked,
              onTap: widget.likePost,
              child: carousel,
            ),
          ),
        if (showImagesCount)
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_showImagesCountText, _currentIndex]),
              builder: (context, child) {
                if (widget.autoHideCurrentIndex) {
                  if (_showImagesCountText.value) {
                    _debouncer.run(() => _showImagesCountText.value = false);
                  }
                }

                return RepaintBoundary(
                  child: _CurrentPostImageIndexOfTotal(
                    currentIndex: _currentIndex.value + 1,
                    total: widget.media.length,
                    showText: _showImagesCountText.value,
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
