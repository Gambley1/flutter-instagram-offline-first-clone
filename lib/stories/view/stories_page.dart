import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:story_view/story_view.dart';
import 'package:user_repository/user_repository.dart';

class StoriesView extends StatelessWidget {
  const StoriesView({
    required this.stories,
    required this.author,
    super.key,
    this.onStorySeen,
  });

  final User author;
  final List<Story> stories;
  final void Function(int storyIndex, List<Story> stories)? onStorySeen;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoriesBloc(
        storiesRepository: context.read<StoriesRepository>(),
        userRepository: context.read<UserRepository>(),
      ),
      child: AppScaffold(
        body: StoryViewDelegate(
          author: author,
          stories: stories,
          onStorySeen: onStorySeen,
        ),
      ),
    );
  }
}

class StoryViewDelegate extends StatelessWidget {
  const StoryViewDelegate({
    required this.author,
    required this.stories,
    required this.onStorySeen,
    super.key,
  });

  final User author;
  final List<Story> stories;
  final void Function(int storyIndex, List<Story> stories)? onStorySeen;

  @override
  Widget build(BuildContext context) {
    final controller = StoryController();
    final storyItems = stories.toStoryItems(controller);
    final createdAt = ValueNotifier<DateTime?>(null);

    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              StoryView(
                storyItems: storyItems,
                controller: controller,
                onStoryShow: (story) {
                  final storyIndex = storyItems.indexOf(story);
                  createdAt.value = stories[storyIndex].createdAt;
                  if (onStorySeen != null) {
                    onStorySeen!.call(storyIndex, stories);
                  } else {
                    if (storyIndex == -1) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context
                          .read<StoriesBloc>()
                          .add(StoriesStorySeen(stories[storyIndex]));
                    });
                  }
                },
                onVerticalSwipeComplete: (_) => context.pop(),
                onComplete: context.pop,
              ),
              ValueListenableBuilder(
                valueListenable: createdAt,
                builder: (context, createdAt, child) {
                  return StoriesAuthorListTile(
                    author: author,
                    createdAt: createdAt,
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: Colors.black,
            child: Row(
              children: [
                Text(
                  'Hello',
                  style: context.bodyLarge
                      ?.copyWith(fontWeight: AppFontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StoriesAuthorListTile extends StatelessWidget {
  const StoriesAuthorListTile({
    required this.author,
    required this.createdAt,
    super.key,
  });

  final User author;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = author.id == user.id;

    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xlg,
        AppSpacing.sm,
        0,
      ),
      horizontalTitleGap: 8,
      leading: UserProfileAvatar(
        isLarge: false,
        avatarUrl: author.avatarUrl,
        userId: author.id,
        onTap: (_) {
          context
            ..pop()
            ..pushNamed(
              'user_profile',
              pathParameters: {'user_id': author.id},
            );
        },
      ),
      title: Row(
        children: [
          Text(
            author.username ?? author.fullName ?? '',
            style: context.bodyLarge?.copyWith(fontWeight: AppFontWeight.bold),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (createdAt != null) Text(createdAt!.timeAgo(context)),
        ],
      ),
      trailing: isMine
          ? null
          : Tappable(
              onTap: () {},
              child: const Icon(Icons.more_vert_outlined),
            ),
    );
  }
}

extension on List<Story> {
  List<StoryItem> toStoryItems(StoryController controller) => map(
        (story) => switch (story.contentType) {
          StoryContentType.image => StoryItem.pageImage(
              url: story.contentUrl,
              shown: story.seen,
              controller: controller,
            ),
          StoryContentType.video => StoryItem.pageVideo(
              story.contentUrl,
              shown: story.seen,
              controller: controller,
              duration: story.duration == null
                  ? null
                  : Duration(milliseconds: story.duration! * 1000),
            )
        },
      ).toList();
}
