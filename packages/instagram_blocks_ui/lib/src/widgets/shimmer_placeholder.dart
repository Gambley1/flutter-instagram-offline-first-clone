import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

typedef PlaceholderImageBuilder = Widget Function(
  double? width,
  double? height,
);

class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({
    this.width,
    this.height,
    this.radius,
    this.borderRadius,
    this.baseColor = const Color(0xff2d2f2f),
    this.baseColorLight,
    this.highlightColor = const Color(0xff13151b),
    this.highlightColorLight,
    this.withAdaptiveColors = true,
    this.child,
    super.key,
    this.placeholderImageBuilder,
  });

  final bool withAdaptiveColors;
  final Color baseColor;
  final Color? baseColorLight;
  final Color highlightColor;
  final Color? highlightColorLight;
  final double? radius;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Widget? child;
  final PlaceholderImageBuilder? placeholderImageBuilder;

  static Widget _defaultPlaceholderImage({
    required double width,
    required double height,
  }) =>
      Assets.images.placeholder.image(
        width: width,
        height: height,
        fit: BoxFit.cover,
      );

  static Widget _defaultCircularPlaceholderImage(double radius) => CircleAvatar(
        backgroundImage: Assets.images.placeholder.provider(),
        radius: radius,
      );

  @override
  Widget build(BuildContext context) {
    final width = this.width ?? double.infinity;
    final height = this.height ?? double.infinity;
    final image = placeholderImageBuilder?.call(width, height) ??
        (radius != null
            ? _defaultCircularPlaceholderImage(radius!)
            : _defaultPlaceholderImage(width: width, height: height));
    final baseColor = withAdaptiveColors
        ? context.customReversedAdaptiveColor(
            dark: this.baseColor,
            light: baseColorLight ?? Colors.white.withOpacity(.4),
          )
        : this.baseColor;
    final highlightColor = withAdaptiveColors
        ? context.customReversedAdaptiveColor(
            dark: this.highlightColor,
            light:
                highlightColorLight ?? const Color.fromARGB(255, 181, 190, 226),
          )
        : this.highlightColor;

    return ClipPath(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      clipper: ShapeBorderClipper(
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius == null
              ? BorderRadius.zero
              : BorderRadius.all(Radius.circular(borderRadius!)),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: child ?? image,
      ),
    );
  }
}
