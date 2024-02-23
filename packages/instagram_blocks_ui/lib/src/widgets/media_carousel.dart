import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/media_carousel_settings.dart';
import 'package:instagram_blocks_ui/src/widgets/octo_blur_placeholder.dart';
import 'package:instagram_blocks_ui/src/widgets/video_play.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:octo_image/octo_image.dart';
import 'package:shared/shared.dart';

class MediaCarousel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final currentIndex = ValueNotifier<int>(0);

    Widget carousel({bool? isInView}) => CarouselSlider.builder(
          itemCount: media.length,
          itemBuilder: (context, index, realIndex) {
            final media = this.media[index];
            final url = media.url;
            final blurHash = media.blurHash;
            if (media is VideoMedia) {
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
            return OctoImage.fromSet(
              key: ValueKey(media.id),
              image: CachedNetworkImageProvider(
                url,
                cacheKey: media.id,
              ),
              octoSet: OctoBlurHashPlaceholder(
                blurHash: blurHash,
                fit: settings.fit,
              ),
              fit: settings.fit,
              gaplessPlayback: true,
              placeholderFadeInDuration: const Duration(milliseconds: 250),
              fadeOutDuration: const Duration(milliseconds: 850),
              fadeInDuration: const Duration(milliseconds: 200),
            );
          },
          options: CarouselOptions(
            aspectRatio: settings.aspectRatio!,
            viewportFraction: settings.viewportFraction!,
            enableInfiniteScroll: settings.enableInfiniteScroll!,
            onPageChanged: (index, reason) {
              currentIndex.value = index;
              settings.onPageChanged?.call(index, reason);
            },
          ),
        );

    if (!settings.withInViewNotifier!) return carousel();

    return InViewNotifierWidget(
      id: '${postIndex!}',
      builder: (context, isInView, _) {
        return carousel(isInView: isInView);
      },
    );
  }
}
