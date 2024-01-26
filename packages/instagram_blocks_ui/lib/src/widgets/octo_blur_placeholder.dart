import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/blur_hash_image_placeholder.dart';
import 'package:octo_image/octo_image.dart';

class OctoBlurHashPlaceholder extends OctoSet {
  OctoBlurHashPlaceholder({
    required this.blurHash,
    this.fit,
    this.message,
    this.icon,
    this.iconColor,
    this.iconSize,
  }) : super(
          placeholderBuilder: blurHash == null || blurHash.isEmpty
              ? OctoPlaceholder.circularProgressIndicator()
              : (_) => OctoBlurPlaceholderBuilder(
                    blurHash: blurHash,
                  ),
          errorBuilder: _defaultBlurHashErrorBuilder(
            blurHash,
            fit: fit,
            message: message,
            icon: icon,
            iconColor: iconColor,
            iconSize: iconSize,
          ),
        );

  static OctoErrorBuilder _defaultBlurHashErrorBuilder(
    String? hash, {
    BoxFit? fit,
    Text? message,
    IconData? icon,
    Color? iconColor,
    double? iconSize,
  }) {
    return OctoError.placeholderWithErrorIcon(
      (context) => hash == null || hash.isEmpty
          ? OctoPlaceholder.circularProgressIndicator().call(context)
          : OctoBlurPlaceholderBuilder(
              blurHash: hash,
              fit: fit,
            ),
      message: message,
      icon: icon,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }

  final String? blurHash;
  final BoxFit? fit;
  final Text? message;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
}

class OctoBlurPlaceholderBuilder extends StatelessWidget {
  const OctoBlurPlaceholderBuilder({
    required this.blurHash,
    super.key,
    this.fit,
  });

  final String blurHash;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return BlurHashImagePlaceholder(
      blurHash: blurHash,
      fit: fit,
      withLoadingIndicator: true,
    );
  }
}
