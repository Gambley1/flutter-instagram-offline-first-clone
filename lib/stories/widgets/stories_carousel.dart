import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/create_stories/create_stories.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class StoriesCarousel extends StatelessWidget {
  const StoriesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return const StoriesListView();
  }
}

class StoriesListView extends StatelessWidget {
  const StoriesListView({
    super.key,
  });

  static const _storiesCarouselHeight = 124.0;

  @override
  Widget build(BuildContext context) {
    final canCreateStory =
        context.select((CreateStoriesBloc bloc) => bloc.state.isAvailable);
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return SliverPadding(
      padding:
          const EdgeInsets.only(top: AppSpacing.xxs, bottom: AppSpacing.xxs),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: _storiesCarouselHeight,
          child: BlocBuilder<StoriesBloc, StoriesState>(
            builder: (context, state) {
              final followings = state.users;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: followings.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final following = index == 0 ? null : followings[index - 1];
                  final isMine = index == 0;

                  return Padding(
                    padding: EdgeInsets.only(left: isMine ? AppSpacing.md : 0),
                    child: StoryAvatar(
                      key: ValueKey(following?.id ?? user.id),
                      author: following ?? user,
                      isMine: isMine,
                      username: following?.displayUsername ?? '',
                      onTap: (_) {
                        if (!canCreateStory) return;
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
                                          title: context
                                              .l10n.somethingWentWrongText,
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
                                          title: context.l10n
                                              .successfullyCreatedStoryText,
                                        ),
                                        clearIfQueue: true,
                                      );
                                    },
                                  ),
                                );
                            context.pop();
                          },
                        );
                      },
                      onLongPress: isMine ? null : () {},
                      avatarBuilder: (
                        context,
                        author,
                        onAvatarTap,
                        isMine,
                        stories,
                        onLongPress,
                      ) {
                        return UserStoriesAvatar(
                          isLarge: true,
                          stories: stories,
                          author: author,
                          onAvatarTap: onAvatarTap,
                          withAddButton: isMine,
                          onLongPress: (_) => onLongPress?.call(),
                          animationEffect: TappableAnimationEffect.scale,
                          showWhenSeen: true,
                          onAddButtonTap: () => onAvatarTap(''),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
