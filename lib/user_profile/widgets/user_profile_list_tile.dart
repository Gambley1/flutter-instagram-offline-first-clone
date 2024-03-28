import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class UserProfileListTile extends StatefulWidget {
  const UserProfileListTile({
    required this.user,
    required this.follower,
    super.key,
  });

  final User user;
  final bool follower;

  @override
  State<UserProfileListTile> createState() => _UserProfileListTileState();
}

class _UserProfileListTileState extends State<UserProfileListTile> {
  late Future<bool> _isFollowed;

  @override
  void initState() {
    super.initState();
    if (widget.follower) {
      _isFollowed = context.read<UserRepository>().isFollowed(
            followerId: context.read<AppBloc>().state.user.id,
            userId: widget.user.id,
          );
    }
  }

  void _removeFollower(BuildContext context) {
    context.confirmAction(
      title: context.l10n.removeFollowerText,
      content: context.l10n.removeFollowerConfirmationText,
      yesText: context.l10n.removeText,
      noText: context.l10n.cancelText,
      fn: () => context
          .read<UserProfileBloc>()
          .add(UserProfileRemoveFollowerRequested(userId: widget.user.id)),
    );
  }

  void _follow(BuildContext context) => context
      .read<UserProfileBloc>()
      .add(UserProfileFollowUserRequested(userId: widget.user.id));

  @override
  Widget build(BuildContext context) {
    final profile = context.select((UserProfileBloc bloc) => bloc.state.user);
    final me = context.select((AppBloc bloc) => bloc.state.user);
    final isMe = widget.user.id == me.id;
    final isMine = me.id == profile.id;

    return Tappable(
      onTap: () => context.pushNamed(
        'user_profile',
        pathParameters: {'user_id': widget.user.id},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            UserStoriesAvatar(
              author: widget.user,
              withAdaptiveBorder: false,
              enableInactiveBorder: false,
              radius: 26,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle(
                          style: context.bodyLarge!.copyWith(
                            fontWeight: AppFontWeight.semiBold,
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.user.displayUsername,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.follower && isMine)
                                FollowTextButton(
                                  wasFollowed: _isFollowed,
                                  user: widget.user,
                                ),
                            ],
                          ),
                        ),
                        Text(
                          widget.user.displayFullName,
                          style: context.labelLarge?.copyWith(
                            fontWeight: AppFontWeight.medium,
                            color: AppColors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Gap.h(AppSpacing.md),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!(isMe && !isMine))
                          UserActionButton(
                            user: widget.user,
                            follower: widget.follower,
                            isMine: isMine,
                            isMe: isMe,
                            onTap: () => widget.follower
                                ? !isMine
                                    ? _follow(context)
                                    : _removeFollower(context)
                                : _follow(context),
                          ),
                        if (isMine) ...[
                          const Gap.h(AppSpacing.md),
                          Flexible(
                            child: Tappable(
                              onTap: !widget.follower
                                  ? () {}
                                  : () => _removeFollower(context),
                              child: const Icon(Icons.more_vert),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ].spacerBetween(width: AppSpacing.md),
        ),
      ),
    );
  }
}

class UserActionButton extends StatelessWidget {
  const UserActionButton({
    required this.user,
    required this.isMe,
    required this.isMine,
    required this.follower,
    required this.onTap,
    super.key,
  });

  final User user;
  final bool isMe;
  final bool isMine;
  final bool follower;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const padding = EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.xs,
    );
    final textStyle =
        context.bodyLarge?.copyWith(fontWeight: AppFontWeight.semiBold);
    const fadeStrength = FadeStrength.medium;

    late final Widget followerRemoveButton = UserProfileButton(
      onTap: onTap,
      label: context.l10n.removeText,
      padding: padding,
      textStyle: textStyle,
      fadeStrength: fadeStrength,
    );
    late final Widget followingButton = BetterStreamBuilder(
      stream: context.read<UserRepository>().followingStatus(userId: user.id),
      builder: (context, isFollowed) {
        return UserProfileButton(
          onTap: onTap,
          label: isFollowed ? l10n.followingUser : l10n.followUser,
          padding: padding,
          textStyle: textStyle,
          fadeStrength: fadeStrength,
          color: isFollowed
              ? null
              : context.customReversedAdaptiveColor(
                  light: AppColors.lightBlue,
                  dark: AppColors.blue,
                ),
        );
      },
    );

    final child = switch ((follower, isMine, isMe)) {
      (true, true, false) => followerRemoveButton,
      (true, false, false) => followingButton,
      (false, true, false) => followingButton,
      (false, false, false) => followingButton,
      _ => null,
    };

    return switch (child) {
      null => const SizedBox.shrink(),
      final Widget child => Flexible(flex: 9, child: child),
    };
  }
}

class FollowTextButton extends StatelessWidget {
  const FollowTextButton({
    required this.wasFollowed,
    required this.user,
    super.key,
  });

  final Future<bool> wasFollowed;
  final User user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<bool>(
      future: wasFollowed,
      builder: (context, snapshot) {
        final wasFollowed = snapshot.data;
        if (wasFollowed == null || wasFollowed) {
          return const SizedBox.shrink();
        }
        return BetterStreamBuilder<bool>(
          stream:
              context.read<UserRepository>().followingStatus(userId: user.id),
          builder: (context, followed) {
            if (followed && wasFollowed) {
              return const SizedBox.shrink();
            }
            return Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ' • ',
                    style: context.bodyMedium,
                  ),
                  TextSpan(
                    text: followed ? l10n.followingUser : l10n.followUser,
                    style: context.bodyMedium?.copyWith(
                      color: followed ? AppColors.white : AppColors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.read<UserProfileBloc>().add(
                            UserProfileFollowUserRequested(userId: user.id),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
