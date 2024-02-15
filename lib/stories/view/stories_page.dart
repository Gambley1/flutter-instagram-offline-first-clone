import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
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
import 'package:visibility_detector/visibility_detector.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({
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
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: StoriesView(
          author: author,
          stories: stories,
          onStorySeen: onStorySeen,
        ),
      ),
    );
  }
}

class StoriesView extends StatefulWidget {
  const StoriesView({
    required this.author,
    required this.stories,
    required this.onStorySeen,
    super.key,
  });

  final User author;
  final List<Story> stories;
  final void Function(int storyIndex, List<Story> stories)? onStorySeen;

  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> with SafeSetStateMixin {
  late StoryController _controller;
  late List<StoryItem> _storyItems;

  final _currentStory = ValueNotifier<Story>(Story.empty);
  final _createdAt = ValueNotifier<DateTime?>(null);
  final _showOverlay = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _controller = StoryController();
    _storyItems = widget.stories.toStoryItems(_controller);
    _controller.playbackNotifier.listen((state) {
      if (state != PlaybackState.pause) _showOverlay.value = true;
      if (state == PlaybackState.pause) _showOverlay.value = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return Stack(
      children: [
        VisibilityDetector(
          key: ValueKey(user.id),
          onVisibilityChanged: (info) {
            if (!info.visibleBounds.isEmpty) {
              if (_controller.playbackNotifier.value == PlaybackState.pause) {
                if (mounted) _controller.play();
              }
            } else {
              if (mounted) _controller.pause();
            }
          },
          child: StoryView(
            storyItems: _storyItems,
            controller: _controller,
            inline: true,
            onStoryShow: (story) {
              final storyIndex = _storyItems.indexOf(story);
              _currentStory.value = widget.stories[storyIndex];
              _createdAt.value = widget.stories[storyIndex].createdAt;
              if (widget.onStorySeen != null) {
                widget.onStorySeen!.call(storyIndex, widget.stories);
              } else {
                if (storyIndex == -1) return;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<StoriesBloc>().add(
                        StoriesStorySeen(widget.stories[storyIndex], user.id),
                      );
                });
              }
            },
            onVerticalSwipeComplete: (_) => context.pop(),
            onComplete: () {
              if (context.canPop()) context.pop();
            },
          ),
        ),
        AnimatedBuilder(
          animation: Listenable.merge([_createdAt, _showOverlay]),
          builder: (context, child) {
            return AnimatedOpacity(
              opacity: _showOverlay.value ? 1 : 0,
              duration: 200.ms,
              child: StoriesAuthorListTile(
                author: widget.author,
                createdAt: _createdAt.value,
              ),
            );
          },
        ),
        Positioned(
          right: 24,
          bottom: 24,
          child: AnimatedBuilder(
            animation: Listenable.merge([_showOverlay, _currentStory]),
            builder: (context, _) {
              return AnimatedOpacity(
                opacity: _showOverlay.value ? 1 : 0,
                duration: 200.ms,
                child: StoryOptions(
                  controller: _controller,
                  author: widget.author,
                  currentStory: _currentStory.value,
                  onStoryDeleted: (story) {
                    final storyIndex = widget.stories.indexOf(story);
                    if (storyIndex == -1) return;
                    if (_storyItems.length == 1) {
                      safeSetState(() {
                        _storyItems
                          ..addAll([Story.empty].toStoryItems(_controller))
                          ..removeAt(storyIndex);
                      });
                      _currentStory.value = Story.empty;
                      if (context.canPop()) context.pop();
                    } else {
                      safeSetState(() => _storyItems.removeAt(storyIndex));
                      _controller.previous();
                      _currentStory.value = widget
                          .stories[min(storyIndex, _storyItems.length - 1)];
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class StoryOptions extends StatelessWidget {
  const StoryOptions({
    required this.currentStory,
    required this.controller,
    required this.author,
    required this.onStoryDeleted,
    super.key,
  });

  final Story currentStory;
  final StoryController controller;
  final User author;
  final ValueSetter<Story> onStoryDeleted;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = author.id == user.id;

    if (!isMine) return const SizedBox.shrink();

    return Row(
      children: [
        Tappable(
          onTap: () async {
            void callback(ModalOption option) => option.onTap.call(context);

            controller.pause();
            final option = await context.showListOptionsModal(
              options: [
                ModalOption(
                  name: 'Delete story',
                  actionTitle: 'Delete story',
                  actionContent: 'Are you sure you want to delete this story?',
                  actionYesText: 'Delete',
                  child: Assets.icons.trash.svg(
                    height: AppSize.iconSize,
                    colorFilter:
                        const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                  ),
                  nameColor: Colors.red,
                  distractive: true,
                  noAction: (context) {
                    context.pop(false);
                    controller.play();
                  },
                  onTap: () => context.read<StoriesBloc>().add(
                        StoriesStoryDeleteRequested(
                          id: currentStory.id,
                          onStoryDeleted: () {
                            onStoryDeleted.call(currentStory);
                          },
                        ),
                      ),
                ),
              ],
            );
            if (option == null) {
              controller.play();
              return;
            }
            callback(option);
          },
          child: Column(
            children: [
              const Icon(Icons.more_vert_outlined),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'More',
                style: context.bodyMedium?.copyWith(
                  fontWeight: AppFontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ],
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
        onTap: (_) => context.pushNamed(
          'user_profile',
          pathParameters: {'user_id': author.id},
        ),
      ),
      title: Row(
        children: [
          Text.rich(
            overflow: TextOverflow.ellipsis,
            style: context.bodyLarge?.copyWith(
              fontWeight: AppFontWeight.bold,
              color: context.adaptiveColor,
            ),
            TextSpan(
              text: author.displayUsername,
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.pushNamed(
                      'user_profile',
                      pathParameters: {'user_id': author.id},
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (createdAt != null)
            Text(
              createdAt!.timeAgo(context),
              style: context.bodyLarge?.apply(color: context.adaptiveColor),
            ),
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
          StoryContentType.image => StoryItem.inlineImage(
              url: story.contentUrl,
              shown: story.seen,
              controller: controller,
              roundedTop: false,
            ),
          StoryContentType.video => StoryItem.pageVideo(
              story.contentUrl,
              shown: story.seen,
              controller: controller,
              duration:
                  story.duration == null ? null : (story.duration! * 1000).ms,
            )
        },
      ).toList();
}
