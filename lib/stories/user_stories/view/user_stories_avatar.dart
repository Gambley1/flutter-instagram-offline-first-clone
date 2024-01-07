import 'dart:convert';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

typedef OnAvatarTapCallback = void Function(String? avatarUrl);

class UserStoriesAvatar extends StatelessWidget {
  const UserStoriesAvatar({
    required this.author,
    this.onAvatarTap,
    this.withAddButton = false,
    this.onLongPress,
    this.animationEffect = TappableAnimationEffect.none,
    this.showStories,
    this.showWhenSeen,
    this.isLarge = false,
    this.isImagePicker = false,
    this.enableUnactiveBorder = true,
    this.withShimmerPlaceholder = false,
    this.radius,
    this.scaleStrength = ScaleStrength.xxs,
    this.onImagePick,
    super.key,
  });

  final User author;
  final OnAvatarTapCallback? onAvatarTap;
  final bool withAddButton;
  final VoidCallback? onLongPress;
  final TappableAnimationEffect animationEffect;
  final bool? showStories;
  final bool? showWhenSeen;
  final bool isLarge;
  final bool isImagePicker;
  final bool enableUnactiveBorder;
  final bool withShimmerPlaceholder;
  final ScaleStrength scaleStrength;
  final double? radius;
  final ValueSetter<String>? onImagePick;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserStoriesBloc(
        author: author,
        storiesRepository: context.read<StoriesRepository>(),
      )..add(const UserStoriesSubscriptionRequested()),
      child: ProfileAvatar(
        author: author,
        onAvatarTap: onAvatarTap,
        withAddButton: withAddButton,
        animationEffect: animationEffect,
        showStories: showStories,
        showWhenSeen: showWhenSeen,
        isLarge: isLarge,
        isImagePicker: isImagePicker,
        onImagePick: onImagePick,
        enableUnactiveBorder: enableUnactiveBorder,
        withShimmerPlaceholder: withShimmerPlaceholder,
        onLongPress: onLongPress,
        radius: radius,
        scaleStrength: scaleStrength,
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.author,
    required this.onAvatarTap,
    required this.withAddButton,
    required this.animationEffect,
    required this.isLarge,
    required this.isImagePicker,
    required this.enableUnactiveBorder,
    required this.withShimmerPlaceholder,
    required this.scaleStrength,
    required this.showStories,
    required this.showWhenSeen,
    required this.onLongPress,
    required this.radius,
    required this.onImagePick,
    super.key,
  });

  final User author;
  final OnAvatarTapCallback? onAvatarTap;
  final bool withAddButton;
  final VoidCallback? onLongPress;
  final TappableAnimationEffect animationEffect;
  final bool? showStories;
  final bool? showWhenSeen;
  final bool isLarge;
  final bool isImagePicker;
  final bool enableUnactiveBorder;
  final bool withShimmerPlaceholder;
  final double? radius;
  final ScaleStrength scaleStrength;
  final ValueSetter<String>? onImagePick;

  @override
  Widget build(BuildContext context) {
    final stories =
        context.select((UserStoriesBloc bloc) => bloc.state.stories);
    final showStories =
        context.select((UserStoriesBloc bloc) => bloc.state.showStories);
    return UserProfileAvatar(
      userId: author.id,
      stories: stories,
      showStories: this.showStories ?? showStories,
      avatarUrl: author.avatarUrl,
      isLarge: isLarge,
      isImagePicker: isImagePicker,
      onImagePick: onImagePick,
      withAddButton: withAddButton,
      onLongPress: onLongPress,
      radius: radius,
      animationEffect: animationEffect,
      scaleStrength: scaleStrength,
      enableUnactiveBorder: enableUnactiveBorder,
      withShimmerPlaceholder: withShimmerPlaceholder,
      onTap: (avatarUrl) {
        if (this.showStories ?? true && (showWhenSeen ?? false)) {
          context.pushNamed(
            'view_stories',
            queryParameters: {
              'stories': json.encode(stories.map((e) => e.toJson()).toList()),
            },
            extra: author,
          );
        } else {
          onAvatarTap?.call(avatarUrl);
        }
        // if (this.showStories ?? showStories) {
        //   for (final story in stories.whereNot((story) => story.seen)) {
        //     context
        //         .read<UserStoriesBloc>()
        //         .add(UserStoriesStorySeenRequested(story));
        //   }
        // }
      },
    );
  }
}
