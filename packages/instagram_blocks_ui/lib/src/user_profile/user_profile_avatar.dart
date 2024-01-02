import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

class UserProfileAvatar extends StatelessWidget {
  const UserProfileAvatar({
    this.hasStories = false,
    this.hasUnseenStories,
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
  });

  final bool hasStories;
  final bool? hasUnseenStories;
  final String? userId;
  final String? avatarUrl;
  final double? radius;
  final bool isLarge;
  final bool isImagePicker;
  final ValueSetter<String?>? onTap;
  final VoidCallback? onLongPress;
  final ValueSetter<String>? onImagePick;
  final TappableAnimationEffect animationEffect;
  final ScaleStrength scaleStrength;
  final bool withAddButton;
  final bool enableBorder;
  final bool enableUnactiveBorder;

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
      BorderSide(width: 0.2, color: Colors.grey.shade500),
    ),
  );

  Future<void> _pickImage() async {
    final imageFile = await PickImage.imageWithXImagePicker(
      source: ImageSource.gallery,
    );
    if (imageFile == null) return;

    final avatarsStorage = Supabase.instance.client.storage.from('avatars');

    final bytes = await imageFile.readAsBytes();
    final fileExt = imageFile.path.split('.').last;
    final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
    final filePath = fileName;
    await avatarsStorage.uploadBinary(
      filePath,
      bytes,
      fileOptions: FileOptions(contentType: imageFile.mimeType),
    );
    final imageUrlResponse =
        await avatarsStorage.createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
    onImagePick?.call(imageUrlResponse);
  }

  @override
  Widget build(BuildContext context) {
    final radius = (this.radius) ?? (isLarge ? 42.0 : 22.0);

    BoxDecoration? border() {
      if (avatarUrl == null || (avatarUrl!.isEmpty)) return null;
      if (!enableBorder) return null;
      if (!hasStories && !enableUnactiveBorder) return null;
      if (!enableUnactiveBorder && !hasStories) return null;
      if (enableUnactiveBorder && !hasStories) return null;
      if (hasUnseenStories ?? false) {
        return _gradientBorderDecoration;
      }
      if (hasUnseenStories != null &&
          hasUnseenStories! == false &&
          hasStories) {
        return _greyBorderDecoration;
      }
      return _greyBorderDecoration;
    }

    late Widget avatar;

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
                    placeholder: (context, url) => CircleAvatar(
                      backgroundColor: context.customReversedAdaptiveColor(
                        light: Colors.white60,
                      ),
                      radius: radius,
                    ),
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
      onLongPress: isImagePicker ? _pickImage : onLongPress,
      animationEffect: animationEffect,
      scaleStrength: scaleStrength,
      child: avatar,
    );
  }
}
