import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({
    this.userId,
    super.key,
  });

  final String? userId;

  @override
  Widget build(BuildContext context) {
    void navigateToSubscribersPage(BuildContext context) => context.pushNamed(
          'user_statistics',
          extra: '0',
          queryParameters: {
            'user_id': userId,
          },
        );

    void navigateToSubscriptionsPage(BuildContext context) => context.pushNamed(
          'user_statistics',
          extra: '1',
          queryParameters: {
            'user_id': userId,
          },
        );

    final bloc = context.read<UserProfileBloc>();
    final isOwner = context.select((UserProfileBloc b) => b.isOwner);
    // final user = context.select((UserProfileBloc b) => b.state.user);
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Row(
              children: [
                UserStoriesAvatar(
                  author: user,
                  isImagePicker: isOwner,
                  onAvatarTap: (imageUrl) {
                    if (imageUrl == null) return;
                    context.showImagePreview(imageUrl);
                  },
                  isLarge: true,
                  animationEffect: TappableAnimationEffect.scale,
                  onImagePick: (imageUrl) => bloc.add(
                    UserProfileUpdateRequested(avatarUrl: imageUrl),
                  ),
                  showWhenSeen: true,
                ),
                const SizedBox(width: 12),
                UserProfileListStatistics(
                  onSubscribersTap: () => navigateToSubscribersPage(context),
                  onSubscribesTap: () => navigateToSubscriptionsPage(context),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                user.fullName ?? '',
                style:
                    context.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isOwner) ...[
                  const Expanded(child: UserEditProfileButton()),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(child: UserEditProfileButton()),
                ] else
                  UserProfileSubscribeUserButton(userId: userId),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileListStatistics extends StatelessWidget {
  const UserProfileListStatistics({
    required this.onSubscribersTap,
    required this.onSubscribesTap,
    super.key,
  });

  final VoidCallback onSubscribersTap;
  final VoidCallback onSubscribesTap;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserProfileBloc>();

    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              child: StreamBuilder<int>(
                stream: bloc.postsAmountOf(),
                builder: (context, snapshot) {
                  final count = snapshot.data;
                  return UserProfileStatistic(
                    name: context.l10n.postsCount(count ?? 0),
                    value: bloc.postsAmountOf(),
                    onTap: () {},
                  );
                },
              ),
            ),
          ),
          Flexible(
            child: FittedBox(
              child: UserProfileStatistic(
                name: context.l10n.followersText,
                value: bloc.followersCountOf(),
                onTap: onSubscribersTap,
              ),
            ),
          ),
          Flexible(
            child: FittedBox(
              child: UserProfileStatistic(
                name: context.l10n.followingsText,
                value: bloc.followingsCountOf(),
                onTap: onSubscribesTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserEditProfileButton extends StatelessWidget {
  const UserEditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      animationEffect: TappableAnimationEffect.none,
      borderRadius: 6,
      color: context.customReversedAdaptiveColor(
        light: Colors.grey.shade300,
        dark: const Color.fromARGB(255, 40, 37, 37).withOpacity(.9),
      ),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            context.l10n.editProfileText,
            style: context.labelLarge,
          ),
        ),
      ),
    );
  }
}

class UserProfileSubscribeUserButton extends StatelessWidget {
  const UserProfileSubscribeUserButton({required this.userId, super.key});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserProfileBloc>();
    final user = context.select((UserProfileBloc b) => b.state.user);
    return StreamBuilder<bool>(
      stream: bloc.followingStatus(userId: userId!),
      builder: (context, snapshot) {
        final isSubscribed = snapshot.data;
        if (isSubscribed == null) {
          return const SizedBox.shrink();
        }
        return Tappable(
          animationEffect: TappableAnimationEffect.none,
          borderRadius: 6,
          color: isSubscribed
              ? context.customReversedAdaptiveColor(
                  light: Colors.grey.shade300,
                  dark: const Color.fromARGB(255, 40, 37, 37).withOpacity(.9),
                )
              : context.customReversedAdaptiveColor(
                  light: Colors.blue.shade300,
                  dark: Colors.blue.shade500,
                ),
          onTap: isSubscribed
              ? () async {
                  final option = await context.showListOptionsModal(
                    title: user.username,
                    options: subscriberModalOptions(
                      cancelSubscriptionLabel: context.l10n.cancelFollowingText,
                      cancelSubscription: () => context
                          .read<UserProfileBloc>()
                          .add(UserProfileFollowUserRequested(userId!)),
                    ),
                  );
                  if (option == null) return;
                  option.onTap?.call();
                }
              : () => context.read<UserProfileBloc>().add(
                    UserProfileFollowUserRequested(userId!),
                  ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              isSubscribed ? 'Subscriptions ▼' : 'Subscribe ',
              style: context.labelLarge,
            ),
          ),
        );
      },
    );
  }
}
