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
    this.onTapPickImage = false,
    this.strokeWidth,
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
    this.withAdaptiveBorder = true,
  });

  final List<Story> stories;
  final String? userId;
  final String? avatarUrl;
  final double? radius;
  final double? strokeWidth;
  final bool isLarge;
  final bool isImagePicker;
  final bool onTapPickImage;
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
  final bool withAdaptiveBorder;

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

  static const _defaultGradient = SweepGradient(
    colors: [
      Color(0xFF833AB4), // Purple
      Color(0xFFF77737), // Orange
      Color(0xFFE1306C), // Red-pink
      Color(0xFFC13584), // Red-purple
      Color(0xFF833AB4), // Duplicate of the first color
    ],
    // Adjust the stops to create a smoother transition
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  static const _gradientBorderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: _defaultGradient,
  );

  static const _blackBorderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.fromBorderSide(BorderSide(width: 3)),
  );

  static const _whiteBorderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.fromBorderSide(BorderSide(width: 3, color: Colors.white)),
  );

  BoxDecoration _greyBorderDecoration(BuildContext context) => BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(
            color: context.customReversedAdaptiveColor(
              dark: Colors.grey.shade800,
              light: Colors.grey.shade400,
            ),
          ),
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
      fileOptions:
          FileOptions(contentType: 'image/$fileExt', cacheControl: '360000'),
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
    final radius = (this.radius) ??
        (isLarge
            ? 42.0
            : withAdaptiveBorder
                ? 22.0
                : 19.0);
    final hasStories = stories.isNotEmpty;

    BoxDecoration? border() {
      if (avatarUrl == null || (avatarUrl!.isEmpty)) return null;
      if (!hasStories) return null;
      if (!enableUnactiveBorder && !showStories) return null;
      if (showStories && hasStories) return _gradientBorderDecoration;
      if (enableUnactiveBorder && !showStories && hasStories) {
        return _greyBorderDecoration(context);
      }
      return null;
    }

    Gradient? gradient() {
      if (avatarUrl == null || (avatarUrl!.isEmpty)) return null;
      if (!hasStories) return null;
      if (!enableUnactiveBorder && !showStories) return null;
      if (showStories && hasStories) return _defaultGradient;
      if (enableUnactiveBorder && !showStories && hasStories) {
        return LinearGradient(
          colors: [Colors.grey.shade600, Colors.grey.shade600],
        );
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

    final image = CachedNetworkImage(
      imageUrl: avatarUrl ?? '',
      fit: BoxFit.cover,
      cacheKey: avatarUrl,
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
    );
    if (!withAdaptiveBorder) {
      avatar = GradientCircleContainer(
        strokeWidth: strokeWidth ?? 2,
        radius: radius * 2 + 12,
        gradient: gradient(),
        child: DecoratedBox(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: avatarUrl == null || (avatarUrl?.isEmpty ?? true)
              ? const SizedBox.shrink()
              : image,
        ),
      );
    } else {
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
                  : image,
            ),
          ],
        ),
      );
    }

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
              size: isLarge ? AppSize.iconSizeSmall : AppSize.iconSizeXSmall,
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
      onTap: onTap == null
          ? !onTapPickImage
              ? null
              : () => _pickImage(context)
          : () => onTap?.call(avatarUrl),
      onLongPress: isImagePicker ? () => _pickImage.call(context) : onLongPress,
      animationEffect: animationEffect,
      scaleStrength: scaleStrength,
      child: avatar,
    );
  }
}

class GradientCircleContainer extends StatelessWidget {
  GradientCircleContainer({
    required double strokeWidth,
    required double radius,
    required this.child,
    Gradient? gradient,
    this.padding = AppSpacing.xs,
    super.key,
  })  : _painter = gradient == null
            ? null
            : _GradientPainter(
                strokeWidth: strokeWidth,
                radius: radius,
                gradient: gradient,
              ),
        _radius = radius;

  final _GradientPainter? _painter;
  final Widget child;
  final double _radius;
  final double padding;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_painter == null) {
      child = this.child;
    } else {
      child = Padding(
        padding: EdgeInsets.all(padding),
        child: this.child,
      );
    }
    return CustomPaint(
      painter: _painter,
      child: SizedBox(
        height: _radius,
        width: _radius,
        child: child,
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  _GradientPainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradient,
  });

  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    final outerRect = Offset.zero & size;
    final outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    final innerRect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );
    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(radius - strokeWidth),
    );

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    final path1 = Path()..addRRect(outerRRect);
    final path2 = Path()..addRRect(innerRRect);
    final path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
