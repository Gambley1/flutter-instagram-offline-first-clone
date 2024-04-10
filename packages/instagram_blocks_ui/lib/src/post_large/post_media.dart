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

  bool get singleImage => widget.media.length == 1;
  bool get showMediaCount => !singleImage && widget.media.isNotEmpty;

  late ValueNotifier<int> _currentIndex;
  late ValueNotifier<bool> _showMediaCount;

  @override
  void initState() {
    super.initState();
    _currentIndex = ValueNotifier(0);
    _showMediaCount = ValueNotifier(!widget.autoHideCurrentIndex);
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    _showMediaCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carousel = MediaCarousel(
      media: widget.media,
      postIndex: widget.postIndex,
      settings: _defaultSettings(_showMediaCount, _currentIndex)
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
        if (showMediaCount)
          _MediaCount(
            currentIndex: _currentIndex,
            showMediaCount: _showMediaCount,
            autoHideCurrentIndex: widget.autoHideCurrentIndex,
            media: widget.media,
          ),
      ],
    );
  }
}

class _MediaCount extends StatefulWidget {
  const _MediaCount({
    required this.currentIndex,
    required this.showMediaCount,
    required this.media,
    required this.autoHideCurrentIndex,
  });

  final ValueNotifier<int> currentIndex;
  final ValueNotifier<bool> showMediaCount;
  final List<Media> media;
  final bool autoHideCurrentIndex;

  @override
  State<_MediaCount> createState() => _MediaCountState();
}

class _MediaCountState extends State<_MediaCount> {
  late Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(milliseconds: 5000);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppSpacing.md,
      right: AppSpacing.md,
      child: AnimatedBuilder(
        animation:
            Listenable.merge([widget.showMediaCount, widget.currentIndex]),
        builder: (context, child) {
          if (widget.autoHideCurrentIndex) {
            if (widget.showMediaCount.value) {
              _debouncer.run(() => widget.showMediaCount.value = false);
            }
          }

          return RepaintBoundary(
            child: _CurrentPostImageIndexOfTotal(
              total: widget.media.length,
              currentIndex: widget.currentIndex.value + 1,
              showText: widget.showMediaCount.value,
            ),
          );
        },
      ),
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
