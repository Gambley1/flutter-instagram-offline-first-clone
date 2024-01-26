import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class BlurHashImagePlaceholder extends StatelessWidget {
  const BlurHashImagePlaceholder({
    required this.blurHash,
    this.fit,
    this.withLoadingIndicator,
    this.indicatorColor,
    super.key,
  });

  final String? blurHash;

  final BoxFit? fit;

  final bool? withLoadingIndicator;

  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    final image = blurHash == null || (blurHash?.isEmpty ?? true)
        ? const SizedBox.shrink()
        : SizedBox.expand(
            child: Image(
              image: BlurHashImage(blurHash!),
              fit: fit ?? BoxFit.cover,
            ),
          );
    if (withLoadingIndicator ?? false) {
      return Stack(
        children: [
          image,
          AppCircularProgress(indicatorColor ?? Colors.white),
        ],
      );
    }
    return image;
  }
}
