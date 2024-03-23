// ignore_for_file: avoid_positional_boolean_parameters

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

typedef StoryAvatarBuilder = Widget Function(
  BuildContext context,
  User author,
  OnAvatarTapCallback onAvatarTap,
  bool isMine,
  List<Story> stories,
  VoidCallback? onLongPress,
);

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    required this.author,
    required this.isMine,
    required this.username,
    required this.onTap,
    super.key,
    this.onLongPress,
    this.avatarBuilder,
  });

  final User author;
  final bool isMine;
  final String username;
  final OnAvatarTapCallback onTap;
  final VoidCallback? onLongPress;
  final StoryAvatarBuilder? avatarBuilder;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return BlocProvider(
      create: (context) => UserStoriesBloc(
        author: author,
        storiesRepository: context.read<StoriesRepository>(),
      )..add(UserStoriesSubscriptionRequested(user.id)),
      child: AvatarView(
        author: author,
        isMine: isMine,
        username: username,
        onTap: onTap,
        avatarBuilder: avatarBuilder,
      ),
    );
  }
}

class AvatarView extends StatelessWidget {
  const AvatarView({
    required this.author,
    required this.isMine,
    required this.username,
    required this.onTap,
    this.onLongPress,
    super.key,
    this.avatarBuilder,
  });

  final User author;
  final bool isMine;
  final String username;
  final OnAvatarTapCallback onTap;
  final VoidCallback? onLongPress;
  final StoryAvatarBuilder? avatarBuilder;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = context.titleSmall!;

    return BlocBuilder<UserStoriesBloc, UserStoriesState>(
      builder: (context, state) {
        final style = isMine
            ? defaultTextStyle
            : !state.stories.every((e) => e.seen)
                ? defaultTextStyle
                : defaultTextStyle.copyWith(color: AppColors.grey);

        return Column(
          children: [
            avatarBuilder?.call(
                  context,
                  author,
                  onTap,
                  isMine,
                  state.stories,
                  onLongPress,
                ) ??
                UserProfileAvatar(
                  withAddButton: isMine,
                  stories: state.stories,
                  onTap: onTap,
                  onLongPress: (_) => onLongPress?.call(),
                  enableInactiveBorder: !isMine,
                  avatarUrl: author.avatarUrl,
                  scaleStrength: ScaleStrength.xxs,
                ),
            const SizedBox(height: AppSpacing.sm - AppSpacing.xxs),
            DefaultTextStyle(
              style: style,
              child: Text(
                isMine ? context.l10n.yourStoryLabel : username,
              ),
            ),
          ],
        );
      },
    );
  }
}
