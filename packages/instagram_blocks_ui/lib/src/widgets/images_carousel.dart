import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/images_carousel_settings.dart';

class ImagesCarousel extends StatelessWidget {
  const ImagesCarousel({
    required this.imagesUrl,
    required this.settings,
    super.key,
  });

  final List<String> imagesUrl;
  final ImagesCarouselSettings settings;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: imagesUrl.length,
      itemBuilder: (context, index, realIndex) {
        final url = imagesUrl[index];
        return CachedNetworkImage(
          imageUrl: url,
          cacheKey: '${url}_$index',
          memCacheHeight: 1080,
          memCacheWidth: 1080,
          errorWidget: (context, url, error) => const SizedBox.shrink(),
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: settings.fit,
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        aspectRatio: settings.aspectRatio,
        viewportFraction: settings.viewportFraction,
        enableInfiniteScroll: settings.enableInfiniteScroll,
        onPageChanged: settings.onPageChanged,
      ),
    );
  }
}
