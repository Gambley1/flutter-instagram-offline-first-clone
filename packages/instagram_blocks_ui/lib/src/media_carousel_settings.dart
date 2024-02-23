// ignore_for_file: public_member_api_docs, avoid_positional_boolean_parameters
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' show BoxFit, BuildContext, Widget;
import 'package:shared/shared.dart';

const kDefaultVideoAspectRatio = 8 / 12;
const kDefaultAspectRatio = 1.0;
const kDefaultMediaBoxFit = BoxFit.cover;
const kDefaultVideoMediaBoxFit = BoxFit.cover;

typedef PageChangedCallback = void Function(
  int index,
  CarouselPageChangedReason reason,
);

typedef VideoPlayerBuilder = Widget Function(
  BuildContext context,
  VideoMedia media,
  double aspectRatio,
  bool shouldPlay,
);

class MediaCarouselSettings {
  const MediaCarouselSettings._({
    this.aspectRatio,
    this.viewportFraction,
    this.enableInfiniteScroll,
    this.fit,
    this.withInViewNotifier,
    this.onPageChanged,
    this.videoPlayerBuilder,
  });

  const MediaCarouselSettings.empty({
    double? aspectRatio,
    double? viewportFraction,
    bool? enableInfiniteScroll,
    BoxFit? fit,
    PageChangedCallback? onPageChanged,
    VideoPlayerBuilder? videoPlayerBuilder,
    bool? withInViewNotifier,
  }) : this._(
          aspectRatio: aspectRatio,
          viewportFraction: viewportFraction,
          enableInfiniteScroll: enableInfiniteScroll,
          fit: fit,
          onPageChanged: onPageChanged,
          videoPlayerBuilder: videoPlayerBuilder,
          withInViewNotifier: withInViewNotifier,
        );

  const MediaCarouselSettings.create({
    double? aspectRatio,
    double? viewportFraction,
    bool? enableInfiniteScroll,
    BoxFit? fit,
    PageChangedCallback? onPageChanged,
    VideoPlayerBuilder? videoPlayerBuilder,
    bool? withInViewNotifier,
  }) : this._(
          aspectRatio: aspectRatio ?? kDefaultAspectRatio,
          viewportFraction: viewportFraction ?? 1,
          enableInfiniteScroll: enableInfiniteScroll ?? false,
          fit: fit ?? kDefaultMediaBoxFit,
          onPageChanged: onPageChanged,
          videoPlayerBuilder: videoPlayerBuilder,
          withInViewNotifier: withInViewNotifier ?? true,
        );

  final double? aspectRatio;
  final double? viewportFraction;
  final bool? enableInfiniteScroll;
  final BoxFit? fit;
  final PageChangedCallback? onPageChanged;
  final VideoPlayerBuilder? videoPlayerBuilder;
  final bool? withInViewNotifier;

  MediaCarouselSettings copyWith({
    double? aspectRatio,
    double? viewportFraction,
    bool? enableInfiniteScroll,
    BoxFit? fit,
    void Function(int, CarouselPageChangedReason)? onPageChanged,
    VideoPlayerBuilder? videoPlayerBuilder,
    bool? withInViewNotifier,
  }) {
    return MediaCarouselSettings._(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      enableInfiniteScroll: enableInfiniteScroll ?? this.enableInfiniteScroll,
      fit: fit ?? this.fit,
      onPageChanged: onPageChanged ?? this.onPageChanged,
      videoPlayerBuilder: videoPlayerBuilder ?? this.videoPlayerBuilder,
      withInViewNotifier: withInViewNotifier ?? this.withInViewNotifier,
    );
  }

  MediaCarouselSettings merge({MediaCarouselSettings? other}) {
    return copyWith(
      fit: other?.fit,
      aspectRatio: other?.aspectRatio,
      enableInfiniteScroll: other?.enableInfiniteScroll,
      onPageChanged: (index, reason) {
        onPageChanged?.call(index, reason);
        other?.onPageChanged?.call(index, reason);
      },
      videoPlayerBuilder: other?.videoPlayerBuilder,
      viewportFraction: other?.viewportFraction,
      withInViewNotifier: other?.withInViewNotifier,
    );
  }
}
