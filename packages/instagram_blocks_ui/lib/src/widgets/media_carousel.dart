import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/widgets/octo_blur_placeholder.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:octo_image/octo_image.dart';
import 'package:shared/shared.dart';

class MediaCarousel extends StatefulWidget {
  const MediaCarousel({
    required this.media,
    required this.settings,
    this.postIndex,
    super.key,
  });

  final List<Media> media;
  final MediaCarouselSettings settings;
  final int? postIndex;

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  late ValueNotifier<int> _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = ValueNotifier(0);
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

  Widget _carousel({bool? isInView}) => CarouselSlider.builder(
        itemCount: widget.media.length,
        itemBuilder: (context, index, realIndex) {
          final media = widget.media[index];
          final url = media.url;
          final blurHash = media.blurHash;

          return switch ('') {
            _ when media is ImageMedia => _MediaCarouselImage(
                blurHash: blurHash,
                url: url,
                media: media,
                settings: widget.settings,
              ),
            _ when media is VideoMedia => _MediaCarouselVideo(
                currentIndex: _currentIndex,
                settings: widget.settings,
                media: media,
                url: url,
                blurHash: blurHash,
                isInView: isInView,
                realIndex: realIndex,
              ),
            _ when media is MemoryImageMedia =>
              _MediaCarouselMemoryImage(media: media),
            _ when media is MemoryVideoMedia => _MediaCarouselMemoryVideo(
                currentIndex: _currentIndex,
                realIndex: realIndex,
                media: media,
                blurHash: blurHash,
                settings: widget.settings,
                isInView: isInView,
              ),
            _ => const SizedBox.shrink()
          };
        },
        options: CarouselOptions(
          aspectRatio: widget.settings.aspectRatio!,
          viewportFraction: widget.settings.viewportFraction!,
          enableInfiniteScroll: widget.settings.enableInfiniteScroll!,
          onPageChanged: (index, reason) {
            _currentIndex.value = index;
            widget.settings.onPageChanged?.call(index, reason);
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (!widget.settings.withInViewNotifier!) return _carousel();
    assert(widget.postIndex != null, 'Post index must be provided!');

    return InViewNotifierWidget(
      id: '${widget.postIndex!}',
      builder: (_, isInView, __) => _carousel(isInView: isInView),
    );
  }
}

class _MediaCarouselVideo extends StatelessWidget {
  const _MediaCarouselVideo({
    required this.currentIndex,
    required this.realIndex,
    required this.settings,
    required this.media,
    required this.url,
    required this.blurHash,
    required this.isInView,
  });

  final ValueNotifier<int> currentIndex;
  final int realIndex;
  final MediaCarouselSettings settings;
  final VideoMedia media;
  final String url;
  final String? blurHash;
  final bool? isInView;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentIndex,
      builder: (context, currentIndex, _) {
        final shouldPlay = currentIndex == realIndex;

        return settings.videoPlayerBuilder?.call(
              context,
              media,
              settings.aspectRatio!,
              (isInView ?? true) && shouldPlay,
            ) ??
            VideoPlay(
              key: ValueKey(media.id),
              url: url,
              play: shouldPlay && (isInView ?? true),
              blurHash: blurHash,
              withSound: false,
              id: media.id,
              aspectRatio: settings.aspectRatio!,
            );
      },
    );
  }
}

class _MediaCarouselMemoryVideo extends StatelessWidget {
  const _MediaCarouselMemoryVideo({
    required this.currentIndex,
    required this.realIndex,
    required this.media,
    required this.blurHash,
    required this.settings,
    required this.isInView,
  });

  final ValueNotifier<int> currentIndex;
  final int realIndex;
  final MemoryVideoMedia media;
  final String? blurHash;
  final MediaCarouselSettings settings;
  final bool? isInView;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentIndex,
      builder: (context, currentIndex, _) {
        final shouldPlay = currentIndex == realIndex;

        return VideoPlay(
          key: ValueKey(media.id),
          id: media.id,
          file: media.file,
          play: shouldPlay && (isInView ?? true),
          blurHash: blurHash,
          aspectRatio: settings.aspectRatio!,
          withPlayControll: false,
          withSoundButton: false,
        );
      },
    );
  }
}

class _MediaCarouselImage extends StatelessWidget {
  const _MediaCarouselImage({
    required this.media,
    required this.url,
    required this.blurHash,
    required this.settings,
  });

  final ImageMedia media;
  final String url;
  final String? blurHash;
  final MediaCarouselSettings settings;

  @override
  Widget build(BuildContext context) {
    final size = (1080 * context.devicePixelRatio).round();
    return OctoImage.fromSet(
      key: ValueKey(media.id),
      image: CachedNetworkImageProvider(url, cacheKey: media.id),
      octoSet: OctoBlurHashPlaceholder(blurHash: blurHash, fit: settings.fit),
      fit: settings.fit,
      memCacheHeight: size,
      memCacheWidth: size,
    );
  }
}

class _MediaCarouselMemoryImage extends StatelessWidget {
  const _MediaCarouselMemoryImage({required this.media});

  final MemoryImageMedia media;

  @override
  Widget build(BuildContext context) {
    return ImageAttachmentThumbnail(
      image: Attachment(
        file: AttachmentFile(size: media.bytes.length, bytes: media.bytes),
      ),
    );
  }
}
