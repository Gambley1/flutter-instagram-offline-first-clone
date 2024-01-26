import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/like_button.dart';
import 'package:instagram_blocks_ui/src/widgets/popping_icon_overlay.dart';
import 'package:shared/shared.dart';

class PostMedia extends StatelessWidget {
  const PostMedia({
    required this.media,
    required this.likePost,
    required this.isLiked,
    required this.withInViewNotifier,
    this.onPageChanged,
    this.videoPlayerBuilder,
    this.postIndex,
    super.key,
  });

  final List<Media> media;
  final int? postIndex;
  final LikeCallback likePost;
  final Stream<bool> isLiked;
  final ValueSetter<int>? onPageChanged;
  final VideoPlayerBuilder? videoPlayerBuilder;
  final bool withInViewNotifier;

  @override
  Widget build(BuildContext context) {
    final currentIndex = ValueNotifier<int>(0);
    final showImagesCountText = ValueNotifier(false);

    final singleImage = media.length == 1;
    final showImagesCount = !singleImage && media.isNotEmpty;

    return Stack(
      children: [
        RepaintBoundary(
          child: PoppingIconAnimationOverlay(
            isLiked: isLiked,
            onTap: likePost,
            child: MediaCarousel(
              media: media,
              postIndex: postIndex,
              settings: MediaCarouselSettings.create(
                videoPlayerBuilder: videoPlayerBuilder,
                aspectRatio: media.hasVideo ? kDefaultVideoAspectRatio : null,
                fit: media.hasVideo ? kDefaultVideoMediaBoxFit : null,
                withInViewNotifier: withInViewNotifier,
                onPageChanged: (index, _) {
                  showImagesCountText.value = true;
                  currentIndex.value = index;
                  onPageChanged?.call(index);
                },
              ),
            ),
          ),
        ),
        if (showImagesCount)
          Positioned(
            top: 12,
            right: 12,
            child: ValueListenableBuilder(
              valueListenable: showImagesCountText,
              builder: (context, showText, child) {
                return ValueListenableBuilder(
                  valueListenable: currentIndex,
                  builder: (context, index, child) {
                    if (showText) {
                      Future.delayed(const Duration(seconds: 5), () {
                        showImagesCountText.value = false;
                      });
                    }

                    return RepaintBoundary(
                      child: _CurrentPostImageInexOfTotal(
                        currentIndex: index + 1,
                        total: media.length,
                        showText: showText,
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CurrentPostImageInexOfTotal extends StatelessWidget {
  const _CurrentPostImageInexOfTotal({
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
      duration: const Duration(milliseconds: 150),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: context.customAdaptiveColor(
            light: Colors.black87,
            dark: Colors.black45,
          ),
        ),
        child: Text(
          text,
        ),
      ),
    );
  }
}
