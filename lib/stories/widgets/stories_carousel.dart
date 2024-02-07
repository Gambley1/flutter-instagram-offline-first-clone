import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/create_stories/create_stories.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
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
      padding: const EdgeInsets.only(top: 2, bottom: 2),
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
                    padding: EdgeInsets.only(left: isMine ? 12 : 0),
                    child: StoryAvatar(
                      key: ValueKey(following?.id ?? user.id),
                      author: following ?? user,
                      isMine: isMine,
                      username:
                          following?.username ?? following?.fullName ?? '',
                      myStoryLabel: context.l10n.yourStoryLabel,
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
                      },
                      onLongPress: isMine ? null : () {},
                      avatarBuilder:
                          (context, author, onAvatarTap, isMine, onLongPress) {
                        return UserStoriesAvatar(
                          isLarge: true,
                          author: author,
                          onAvatarTap: onAvatarTap,
                          withAddButton: isMine,
                          onLongPress: onLongPress,
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
