import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

typedef UserProfilePlaceholderBuilder = Widget Function(
  BuildContext context,
  String url,
);

class UserProfileAvatar extends StatelessWidget {
  const UserProfileAvatar({
    this.stories = const [],
    this.userId,
    super.key,
    this.avatarUrl,
    this.radius,
    this.isLarge = true,
    this.isImagePicker = false,
    this.onTap,
    this.onLongPress,
    this.onImagePick,
    this.animationEffect = TappableAnimationEffect.none,
    this.scaleStrength = ScaleStrength.xs,
    this.withAddButton = false,
    this.enableBorder = true,
    this.enableUnactiveBorder = false,
    this.withShimmerPlaceholder = false,
    this.placeholderBuilder,
    this.showStories = false,
    this.onAddButtonTap,
  });

  final List<Story> stories;
  final String? userId;
  final String? avatarUrl;
  final double? radius;
  final bool isLarge;
  final bool isImagePicker;
  final bool withShimmerPlaceholder;
  final ValueSetter<String?>? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onAddButtonTap;
  final ValueSetter<String>? onImagePick;
  final TappableAnimationEffect animationEffect;
  final ScaleStrength scaleStrength;
  final bool withAddButton;
  final bool enableBorder;
  final bool enableUnactiveBorder;
  final UserProfilePlaceholderBuilder? placeholderBuilder;
  final bool showStories;

  static Widget _defaultPlaceholder({
    required BuildContext context,
    required double radius,
  }) =>
      CircleAvatar(
        backgroundColor: context.customReversedAdaptiveColor(
          light: Colors.white60,
        ),
        radius: radius,
      );

  static const _gradientBorderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    // https://brandpalettes.com/instsagram-color-codes/
    gradient: SweepGradient(
      colors: [
        Color(0xFF833AB4), // Purple
        Color(0xFFF77737), // Orange
        Color(0xFFE1306C), // Red-pink
        Color(0xFFC13584), // Red-purple
        Color(0xFF833AB4), // Duplicate of the first color
      ],
      // Adjust the stops to create a smoother transition
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    ),
  );

  static const _blackBorderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.fromBorderSide(BorderSide(width: 3)),
  );

  static const _whiteBorderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.fromBorderSide(BorderSide(width: 3, color: Colors.white)),
  );

  static final _greyBorderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.fromBorderSide(
      BorderSide(color: Colors.grey.shade800),
    ),
  );

  Future<void> _pickImage(BuildContext context) async {
    Future<void> precacheAvatarUrl(String url) =>
        precacheImage(CachedNetworkImageProvider(url), context);

    final imageFile =
        await PickImage.pickImage(context, source: ImageSource.both);
    if (imageFile == null) return;

    final selectedFile = imageFile.selectedFiles.firstOrNull;
    if (selectedFile == null) return;
    final compressed =
        await ImageCompress.compressFile(selectedFile.selectedFile);
    final compressedFile = compressed == null ? null : File(compressed.path);
    final file = compressedFile ?? selectedFile.selectedFile;
    final compressedBytes = compressedFile == null
        ? null
        : await PickImage.imageBytes(file: compressedFile);
    final bytes = compressedBytes ?? selectedFile.selectedByte;
    final avatarsStorage = Supabase.instance.client.storage.from('avatars');

    final fileExt = file.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
    final filePath = fileName;
    await avatarsStorage.uploadBinary(
      filePath,
      bytes,
      fileOptions: FileOptions(contentType: 'image/$fileExt'),
    );
    final imageUrlResponse =
        await avatarsStorage.createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
    try {
      await precacheAvatarUrl(imageUrlResponse);
    } catch (error, stackTrace) {
      logE(
        'Failed to precache avatar url',
        error: error,
        stackTrace: stackTrace,
      );
    }
    onImagePick?.call(imageUrlResponse);
  }

  @override
  Widget build(BuildContext context) {
    final radius = (this.radius) ?? (isLarge ? 42.0 : 22.0);
    final hasStories = stories.isNotEmpty;

    BoxDecoration? border() {
      if (avatarUrl == null || (avatarUrl!.isEmpty)) return null;
      if (!hasStories) return null;
      if (!enableUnactiveBorder && !showStories) return null;
      if (showStories && hasStories) return _gradientBorderDecoration;
      if (enableUnactiveBorder && !showStories && hasStories) {
        return _greyBorderDecoration;
      }
      return null;
    }

    late Widget avatar;

    Widget placeholder(BuildContext context, String url) =>
        withShimmerPlaceholder
            ? ShimmerPlaceholder(radius: radius)
            : placeholderBuilder?.call(context, url) ??
                _defaultPlaceholder(
                  context: context,
                  radius: radius,
                );

    avatar = Container(
      height: radius * 2 + 12,
      width: radius * 2 + 12,
      decoration: border(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: border() != null
                ? context.isDark
                    ? _blackBorderDecoration
                    : _whiteBorderDecoration
                : null,
            child: avatarUrl == null || (avatarUrl?.isEmpty ?? true)
                ? const SizedBox.shrink()
                : CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    cacheKey: '${avatarUrl}_$userId',
                    memCacheHeight: (radius * 2 + 12).toInt(),
                    memCacheWidth: (radius * 2 + 12).toInt(),
                    errorWidget: (_, __, ___) => CircleAvatar(
                      backgroundColor: context.customReversedAdaptiveColor(
                        light: Colors.white60,
                      ),
                      radius: radius,
                    ),
                    placeholder: placeholder,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: radius,
                      backgroundImage: imageProvider,
                    ),
                  ),
          ),
        ],
      ),
    );

    if (withAddButton) {
      final plusCircularIcon = Positioned(
        bottom: 0,
        right: 0,
        child: Tappable(
          onTap: onAddButtonTap,
          animationEffect: TappableAnimationEffect.scale,
          child: Container(
            width: isLarge ? 32 : 18,
            height: isLarge ? 32 : 18,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                width: isLarge ? 3 : 2,
                color: context.reversedAdaptiveColor,
              ),
            ),
            child: Icon(
              Icons.add,
              size: isLarge ? 20 : 12,
            ),
          ),
        ),
      );
      avatar = Stack(
        children: [
          avatar,
          plusCircularIcon,
        ],
      );
    }

    return Tappable(
      onTap: onTap == null ? null : () => onTap?.call(avatarUrl),
      onLongPress: isImagePicker ? () => _pickImage.call(context) : onLongPress,
      animationEffect: animationEffect,
      scaleStrength: scaleStrength,
      child: avatar,
    );
  }
}
