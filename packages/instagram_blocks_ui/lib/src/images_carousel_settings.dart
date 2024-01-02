// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' show BoxFit;

typedef PageChangedCallback = void Function(
  int index,
  CarouselPageChangedReason reason,
);

class ImagesCarouselSettings {
  final double aspectRatio;
  final double viewportFraction;
  final bool enableInfiniteScroll;
  final BoxFit fit;
  final PageChangedCallback? onPageChanged;

  const ImagesCarouselSettings._({
    required this.aspectRatio,
    required this.viewportFraction,
    required this.enableInfiniteScroll,
    required this.fit,
    this.onPageChanged,
  });

  ImagesCarouselSettings.create({
    double? aspectRatio,
    double? viewportFraction,
    bool? enableInfiniteScroll,
    BoxFit? fit,
    PageChangedCallback? onPageChanged,
  }) : this._(
          aspectRatio: aspectRatio ?? 1,
          viewportFraction: viewportFraction ?? 1,
          enableInfiniteScroll: enableInfiniteScroll ?? false,
          fit: fit ?? BoxFit.contain,
          onPageChanged: onPageChanged,
        );

  ImagesCarouselSettings copyWith({
    double? aspectRatio,
    double? viewportFraction,
    bool? enableInfiniteScroll,
    BoxFit? fit,
    void Function(int, CarouselPageChangedReason)? onPageChanged,
  }) {
    return ImagesCarouselSettings._(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      enableInfiniteScroll: enableInfiniteScroll ?? this.enableInfiniteScroll,
      fit: fit ?? this.fit,
      onPageChanged: onPageChanged ?? this.onPageChanged,
    );
  }
}
