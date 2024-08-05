import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

typedef OnAvatarTapCallback = void Function(String? avatarUrl);

class UserStoriesAvatar extends StatelessWidget {
  const UserStoriesAvatar({
    required this.author,
    this.stories = const [],
    this.onAvatarTap,
    this.withAddButton = false,
    this.onLongPress,
    this.animationEffect = TappableAnimationEffect.none,
    this.showStories,
    this.showWhenSeen,
    this.isLarge = false,
    this.resizeHeight,
    this.resizeWidth,
    this.isImagePicker = false,
    this.enableInactiveBorder = true,
    this.withShimmerPlaceholder = false,
    this.radius,
    this.scaleStrength = ScaleStrength.xxs,
    this.onImagePick,
    this.onAddButtonTap,
    this.withAdaptiveBorder = true,
    super.key,
  });

  final User author;
  final List<Story> stories;
  final OnAvatarTapCallback? onAvatarTap;
  final bool withAddButton;
  final ValueSetter<String?>? onLongPress;
  final TappableAnimationEffect animationEffect;
  final bool? showStories;
  final bool? showWhenSeen;
  final bool isLarge;
  final int? resizeHeight;
  final int? resizeWidth;
  final bool isImagePicker;
  final bool enableInactiveBorder;
  final bool withShimmerPlaceholder;
  final ScaleStrength scaleStrength;
  final double? radius;
  final ValueSetter<String>? onImagePick;
  final VoidCallback? onAddButtonTap;
  final bool withAdaptiveBorder;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    final avatar = ProfileAvatar(
      author: author,
      stories: stories,
      onAvatarTap: onAvatarTap,
      withAddButton: withAddButton,
      animationEffect: animationEffect,
      showStories: showStories,
      showWhenSeen: showWhenSeen,
      isLarge: isLarge,
      resizeHeight: resizeHeight,
      resizeWidth: resizeWidth,
      onImagePick: onImagePick,
      enableInactiveBorder: enableInactiveBorder,
      withShimmerPlaceholder: withShimmerPlaceholder,
      onLongPress: onLongPress,
      onAddButtonTap: onAddButtonTap,
      radius: radius,
      scaleStrength: scaleStrength,
      withAdaptiveBorder: withAdaptiveBorder,
    );

    if (stories.isNotEmpty) return avatar;

    return BlocProvider(
      create: (context) => UserStoriesBloc(
        author: author,
        storiesRepository: context.read<StoriesRepository>(),
      )..add(UserStoriesSubscriptionRequested(user.id)),
      child: avatar,
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.author,
    required this.stories,
    required this.onAvatarTap,
    required this.withAddButton,
    required this.animationEffect,
    required this.isLarge,
    required this.enableInactiveBorder,
    required this.withShimmerPlaceholder,
    required this.scaleStrength,
    required this.showStories,
    required this.showWhenSeen,
    required this.onLongPress,
    required this.radius,
    required this.onImagePick,
    required this.onAddButtonTap,
    required this.withAdaptiveBorder,
    required this.resizeHeight,
    required this.resizeWidth,
    super.key,
  });

  final User author;
  final List<Story> stories;
  final OnAvatarTapCallback? onAvatarTap;
  final bool withAddButton;
  final ValueSetter<String?>? onLongPress;
  final TappableAnimationEffect animationEffect;
  final bool? showStories;
  final bool? showWhenSeen;
  final bool isLarge;
  final int? resizeHeight;
  final int? resizeWidth;
  final bool enableInactiveBorder;
  final bool withShimmerPlaceholder;
  final bool withAdaptiveBorder;
  final double? radius;
  final ScaleStrength scaleStrength;
  final ValueSetter<String>? onImagePick;
  final VoidCallback? onAddButtonTap;

  @override
  Widget build(BuildContext context) {
    final stories = this.stories.isNotEmpty
        ? this.stories
        : context.select((UserStoriesBloc bloc) => bloc.state.stories);
    final showStories =
        context.select((UserStoriesBloc bloc) => bloc.state.showStories);

    void defaultRoute() => context.pushNamed(
          'user_profile',
          pathParameters: {'user_id': author.id},
        );
    return UserProfileAvatar(
      userId: author.id,
      stories: stories,
      showStories: this.showStories ?? showStories,
      avatarUrl: author.avatarUrl,
      isLarge: isLarge,
      resizeHeight: resizeHeight,
      resizeWidth: resizeWidth,
      onImagePick: onImagePick,
      withAddButton: withAddButton,
      onLongPress: onLongPress,
      radius: radius,
      animationEffect: animationEffect,
      scaleStrength: scaleStrength,
      enableInactiveBorder: enableInactiveBorder,
      withShimmerPlaceholder: withShimmerPlaceholder,
      onAddButtonTap: onAddButtonTap,
      withAdaptiveBorder: withAdaptiveBorder,
      onTap: (avatarUrl) {
        if (this.showStories ?? true && stories.isNotEmpty) {
          if (showStories || (!showStories && (showWhenSeen ?? false))) {
            context.pushNamed(
              'stories',
              pathParameters: {'user_id': author.id},
              extra: StoriesProps(stories: stories, author: author),
            );
          } else {
            if (onAvatarTap == null) {
              defaultRoute();
              return;
            }
            onAvatarTap!.call(avatarUrl);
          }
        } else {
          if (onAvatarTap == null) {
            defaultRoute();
            return;
          }
          onAvatarTap?.call(avatarUrl);
        }
      },
    );
  }
}
