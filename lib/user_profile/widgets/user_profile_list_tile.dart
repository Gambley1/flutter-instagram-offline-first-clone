import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
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
      title: 'Remove Follower',
      content: 'Are you sure you want to remove follower?',
      yesText: 'Remove',
      fn: () => context
          .read<UserProfileBloc>()
          .add(UserProfileRemoveFollowerRequested(widget.user.id)),
    );
  }

  void _follow(BuildContext context) => context
      .read<UserProfileBloc>()
      .add(UserProfileFollowUserRequested(widget.user.id));

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
              enableUnactiveBorder: false,
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
                              if (widget.follower)
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
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        UserActionButton(
                          user: widget.user,
                          follower: widget.follower,
                          onTap: () => widget.follower
                              ? _removeFollower(context)
                              : _follow(context),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Flexible(
                          child: Tappable(
                            onTap: widget.follower
                                ? null
                                : () => _removeFollower(context),
                            child: const Icon(Icons.more_vert),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ].insertBetween(const SizedBox(width: AppSpacing.md)),
        ),
      ),
    );
  }
}

class UserActionButton extends StatelessWidget {
  const UserActionButton({
    required this.user,
    required this.follower,
    required this.onTap,
    super.key,
  });

  final User user;
  final bool follower;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    late final Widget followerRemoveButton = Tappable(
      fadeStrength: FadeStrength.medium,
      onTap: onTap,
      borderRadius: 6,
      color: context.customReversedAdaptiveColor(
        light: Colors.grey.shade300,
        dark: const Color.fromARGB(255, 40, 37, 37).withOpacity(.9),
      ),
      child: const FittedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xlg,
            vertical: AppSpacing.xs,
          ),
          child: Align(child: Text('Remove', maxLines: 1)),
        ),
      ),
    );
    late final Widget followingButton = BetterStreamBuilder(
      stream: context.read<UserRepository>().followingStatus(userId: user.id),
      builder: (context, isFollowed) {
        return Tappable(
          fadeStrength: FadeStrength.medium,
          onTap: onTap,
          borderRadius: 6,
          color: isFollowed
              ? context.customReversedAdaptiveColor(
                  light: Colors.grey.shade300,
                  dark: const Color.fromARGB(255, 40, 37, 37).withOpacity(.9),
                )
              : context.customReversedAdaptiveColor(
                  light: Colors.blue.shade300,
                  dark: Colors.blue.shade500,
                ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Align(
              child: Text(
                isFollowed ? 'Following' : 'Follow',
                maxLines: 1,
              ),
            ),
          ),
        );
      },
    );
    return DefaultTextStyle(
      style: context.bodyLarge!.copyWith(
        overflow: TextOverflow.ellipsis,
        fontWeight: AppFontWeight.semiBold,
      ),
      child: Flexible(
        flex: 8,
        child: follower ? followerRemoveButton : followingButton,
      ),
    );
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
    return FutureBuilder<bool>(
      future: wasFollowed,
      builder: (context, snapshot) {
        final wasFollowed = snapshot.data;
        if (wasFollowed == null || wasFollowed) {
          return const SizedBox.shrink();
        }
        return BetterStreamBuilder<bool>(
          stream: context.read<UserRepository>().followingStatus(
                followerId: context.read<AppBloc>().state.user.id,
                userId: user.id,
              ),
          builder: (context, followed) {
            if (followed && wasFollowed) {
              return const SizedBox.shrink();
            }
            return Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ' • ',
                    style: context.bodyLarge,
                  ),
                  TextSpan(
                    text: followed ? 'Following' : 'Follow',
                    style: context.bodyLarge?.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: followed ? AppColors.white : AppColors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.read<UserProfileBloc>().add(
                            UserProfileFollowUserRequested(user.id),
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
