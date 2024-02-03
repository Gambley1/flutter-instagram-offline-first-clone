import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/create_stories/create_stories.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

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

    final isOwner = context.select((UserProfileBloc b) => b.isOwner);
    final user = context.select((UserProfileBloc b) => b.state.user);
    // final user = context.select((AppBloc bloc) => bloc.state.user);
    final canCreateStories =
        context.select((CreateStoriesBloc bloc) => bloc.state.isAvailable);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Row(
              children: [
                UserStoriesAvatar(
                  author: user,
                  isImagePicker: true,
                  onImagePick: (imageUrl) {
                    context
                        .read<UserProfileBloc>()
                        .add(UserProfileUpdateRequested(avatarUrl: imageUrl));
                  },
                  onAvatarTap: (imageUrl) {
                    if (imageUrl == null) return;
                    if (!isOwner) context.showImagePreview(imageUrl);
                    if (isOwner) {
                      if (!canCreateStories) return;
                      context.pushNamed(
                        'create_stories',
                        extra: (String path) {
                          context.read<CreateStoriesBloc>().add(
                                CreateStoriesStoryCreateRequested(
                                  author: user,
                                  contentType: StoryContentType.image,
                                  filePath: path,
                                  onError: (_, __) => openSnackbar(
                                    const SnackbarMessage.error(
                                      title: 'Something went wrong!',
                                      description: 'Failed to create story',
                                    ),
                                  ),
                                  onLoading: () => openSnackbar(
                                    const SnackbarMessage.loading(),
                                  ),
                                  onStoryCreated: () => openSnackbar(
                                    const SnackbarMessage.success(
                                      title: 'Successfully created story!',
                                    ),
                                  ),
                                ),
                              );
                          context.pop();
                        },
                      );
                    }
                  },
                  isLarge: true,
                  animationEffect: TappableAnimationEffect.scale,
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
                if (isOwner)
                  ...<Widget>[
                    const Expanded(flex: 3, child: EditProfileButton()),
                    const Expanded(flex: 3, child: ShareProfileButton()),
                    const Expanded(child: ShowSuggestedPeopleButton()),
                  ].separatedBy(
                    const SizedBox(width: AppSpacing.sm),
                  )
                else
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

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      fadeStrength: FadeStrength.small,
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

class ShareProfileButton extends StatelessWidget {
  const ShareProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      fadeStrength: FadeStrength.small,
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
            context.l10n.shareProfileText,
            style: context.labelLarge,
          ),
        ),
      ),
    );
  }
}

class ShowSuggestedPeopleButton extends StatefulWidget {
  const ShowSuggestedPeopleButton({super.key});

  @override
  State<ShowSuggestedPeopleButton> createState() =>
      _ShowSuggestedPeopleButtonState();
}

class _ShowSuggestedPeopleButtonState extends State<ShowSuggestedPeopleButton> {
  bool _showPeople = false;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      fadeStrength: FadeStrength.small,
      borderRadius: 6,
      color: context.customReversedAdaptiveColor(
        light: Colors.grey.shade300,
        dark: const Color.fromARGB(255, 40, 37, 37).withOpacity(.9),
      ),
      onTap: () => setState(() => _showPeople = !_showPeople),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Align(
          alignment: Alignment.topCenter,
          child: Icon(
            _showPeople ? Icons.person_add_rounded : Icons.person_add_outlined,
            size: 20,
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
