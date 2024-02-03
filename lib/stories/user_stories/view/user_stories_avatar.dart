import 'dart:convert';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
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
    this.onAddButtonTap,
    this.withAdaptiveBorder = true,
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
  final VoidCallback? onAddButtonTap;
  final bool withAdaptiveBorder;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    
    return BlocProvider(
      create: (context) => UserStoriesBloc(
        author: author,
        storiesRepository: context.read<StoriesRepository>(),
      )..add(UserStoriesSubscriptionRequested(user.id)),
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
        onAddButtonTap: onAddButtonTap,
        radius: radius,
        scaleStrength: scaleStrength,
        withAdaptiveBorder: withAdaptiveBorder,
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
    required this.onAddButtonTap,
    required this.withAdaptiveBorder,
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
  final bool withAdaptiveBorder;
  final double? radius;
  final ScaleStrength scaleStrength;
  final ValueSetter<String>? onImagePick;
  final VoidCallback? onAddButtonTap;

  @override
  Widget build(BuildContext context) {
    final stories =
        context.select((UserStoriesBloc bloc) => bloc.state.stories);
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
      isImagePicker: isImagePicker,
      onImagePick: onImagePick,
      withAddButton: withAddButton,
      onLongPress: onLongPress,
      radius: radius,
      animationEffect: animationEffect,
      scaleStrength: scaleStrength,
      enableUnactiveBorder: enableUnactiveBorder,
      withShimmerPlaceholder: withShimmerPlaceholder,
      onAddButtonTap: onAddButtonTap,
      withAdaptiveBorder: withAdaptiveBorder,
      onTap: (avatarUrl) {
        if (this.showStories ?? true && stories.isNotEmpty) {
          if (showStories || (!showStories && (showWhenSeen ?? false))) {
            context.pushNamed(
              'view_stories',
              queryParameters: {
                'stories': json.encode(stories.map((e) => e.toJson()).toList()),
              },
              extra: author,
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
