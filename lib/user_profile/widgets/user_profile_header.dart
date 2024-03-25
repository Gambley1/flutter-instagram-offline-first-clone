import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/create_stories/create_stories.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart' hide Switch;
import 'package:user_repository/user_repository.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({
    this.userId,
    this.sponsoredPost,
    super.key,
  });

  final String? userId;
  final PostSponsoredBlock? sponsoredPost;

  void _navigateToSubscribersPage(BuildContext context) => context.pushNamed(
        'user_statistics',
        extra: 0,
        queryParameters: {
          'user_id': userId,
        },
      );

  void _navigateToSubscriptionsPage(BuildContext context) => context.pushNamed(
        'user_statistics',
        extra: 1,
        queryParameters: {
          'user_id': userId,
        },
      );

  @override
  Widget build(BuildContext context) {
    final isOwner = context.select((UserProfileBloc b) => b.isOwner);
    final user$ = context.select((UserProfileBloc b) => b.state.user);
    final user = sponsoredPost == null
        ? user$
        : user$.isAnonymous
            ? sponsoredPost!.author.toUser
            : user$;
    final canCreateStories =
        context.select((CreateStoriesBloc bloc) => bloc.state.isAvailable);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Row(
              children: [
                UserStoriesAvatar(
                  author: user,
                  onLongPress: (avatarUrl) => avatarUrl == null
                      ? null
                      : context.showImagePreview(avatarUrl),
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
                                  onError: (_, __) {
                                    toggleLoadingIndeterminate(enable: false);
                                    openSnackbar(
                                      SnackbarMessage.error(
                                        title:
                                            context.l10n.somethingWentWrongText,
                                        description: context
                                            .l10n.failedToCreateStoryText,
                                      ),
                                    );
                                  },
                                  onLoading: toggleLoadingIndeterminate,
                                  onStoryCreated: () {
                                    toggleLoadingIndeterminate(enable: false);
                                    openSnackbar(
                                      SnackbarMessage.success(
                                        title: context
                                            .l10n.successfullyCreatedStoryText,
                                      ),
                                      clearIfQueue: true,
                                    );
                                  },
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
                const Gap.h(AppSpacing.md),
                Expanded(
                  child: UserProfileStatisticsCounts(
                    onSubscribersTap: () => _navigateToSubscribersPage(context),
                    onSubscribesTap: () =>
                        _navigateToSubscriptionsPage(context),
                  ),
                ),
              ],
            ),
            const Gap.v(AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                user.displayFullName,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.titleMedium
                    ?.copyWith(fontWeight: AppFontWeight.semiBold),
              ),
            ),
            const Gap.v(AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isOwner)
                  ...<Widget>[
                    const Flexible(flex: 3, child: EditProfileButton()),
                    const Flexible(flex: 3, child: ShareProfileButton()),
                    const Flexible(child: ShowSuggestedPeopleButton()),
                  ].spacerBetween(width: AppSpacing.sm)
                else ...[
                  Expanded(
                    flex: 3,
                    child: UserProfileFollowUserButton(userId: userId),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileStatisticsCounts extends StatelessWidget {
  const UserProfileStatisticsCounts({
    required this.onSubscribersTap,
    required this.onSubscribesTap,
    super.key,
  });

  final VoidCallback onSubscribersTap;
  final VoidCallback onSubscribesTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final postsCount =
        context.select((UserProfileBloc bloc) => bloc.state.postsCount);
    final followersCount =
        context.select((UserProfileBloc bloc) => bloc.state.followersCount);
    final followingsCount =
        context.select((UserProfileBloc bloc) => bloc.state.followingsCount);

    return Row(
      children: <Widget>[
        Expanded(
          child: UserProfileStatistic(
            name: l10n.postsCount(postsCount),
            value: postsCount,
            onTap: () {},
          ),
        ),
        Expanded(
          child: UserProfileStatistic(
            name: l10n.followersText,
            value: followersCount,
            onTap: onSubscribersTap,
          ),
        ),
        Expanded(
          child: UserProfileStatistic(
            name: l10n.followingsText,
            value: followingsCount,
            onTap: onSubscribesTap,
          ),
        ),
      ].spacerBetween(width: AppSpacing.sm),
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return UserProfileButton(
      label: context.l10n.editProfileText,
      onTap: () => context.pushNamed('edit_profile'),
    );
  }
}

class ShareProfileButton extends StatelessWidget {
  const ShareProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return UserProfileButton(
      label: context.l10n.shareProfileText,
      onTap: () {},
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
  var _showPeople = false;

  @override
  Widget build(BuildContext context) {
    return UserProfileButton(
      onTap: () => setState(() => _showPeople = !_showPeople),
      child: Icon(
        _showPeople ? Icons.person_add_rounded : Icons.person_add_outlined,
        size: 20,
      ),
    );
  }
}

class UserProfileFollowUserButton extends StatelessWidget {
  const UserProfileFollowUserButton({required this.userId, super.key});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserProfileBloc>();
    final user = context.select((UserProfileBloc bloc) => bloc.state.user);

    final l10n = context.l10n;

    return BetterStreamBuilder<bool>(
      stream: bloc.followingStatus(userId: userId!),
      builder: (context, isFollowed) {
        return UserProfileButton(
          label: isFollowed ? '${l10n.followingUser} ▼' : l10n.followUser,
          color: isFollowed
              ? null
              : context.customReversedAdaptiveColor(
                  light: AppColors.lightBlue,
                  dark: AppColors.blue,
                ),
          onTap: isFollowed
              ? () async {
                  void callback(ModalOption option) =>
                      option.onTap.call(context);

                  final option = await context.showListOptionsModal(
                    title: user.username,
                    options: followerModalOptions(
                      unfollowLabel: context.l10n.cancelFollowingText,
                      onUnfollowTap: () =>
                          bloc.add(UserProfileFollowUserRequested(userId!)),
                    ),
                  );
                  if (option == null) return;
                  callback.call(option);
                }
              : () => bloc.add(UserProfileFollowUserRequested(userId!)),
        );
      },
    );
  }
}
