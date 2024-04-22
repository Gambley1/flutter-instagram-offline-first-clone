import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:story_view/story_view.dart';
import 'package:user_repository/user_repository.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({required this.props, super.key});

  final StoriesProps props;

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
        body: StoriesView(props: props),
      ),
    );
  }
}

class StoriesView extends StatefulWidget {
  const StoriesView({required this.props, super.key});

  final StoriesProps props;

  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> with SafeSetStateMixin {
  final StoryController _controller = StoryController();

  late ValueNotifier<List<StoryItem>> _storyItems;
  late ValueNotifier<Story> _currentStory;
  late ValueNotifier<DateTime?> _createdAt;
  late ValueNotifier<bool> _showOverlay;
  late ValueNotifier<bool> _wasVisible;

  Color? _textColor;
  Color? _iconColor;

  StoriesProps get props => widget.props;
  final _stories = <Story>[];

  @override
  void initState() {
    super.initState();
    _storyItems = ValueNotifier(<StoryItem>[]);
    _currentStory = ValueNotifier<Story>(Story.empty);
    _createdAt = ValueNotifier<DateTime?>(null);
    _showOverlay = ValueNotifier<bool>(true);
    _wasVisible = ValueNotifier<bool>(false);

    _stories.addAll(props.stories);

    _storyItems.value = props.stories.toStoryItems(_controller);
    _showOverlay.addListener(_showOverlayListener);
  }

  Future<void> _initColor() async {
    final textColor =
        await _useWhiteTextColor(region: Offset.zero & const Size(40, 40))
            .then((isWhite) => isWhite ? AppColors.white : AppColors.black);

    final iconColor = await _useWhiteTextColor(
      region: const Offset(360, 360) & const Size(40, 40),
    ).then((isWhite) => isWhite ? AppColors.white : AppColors.black);
    safeSetState(() {
      _textColor = textColor;
      _iconColor = iconColor;
    });
  }

  Future<bool> _useWhiteTextColor({required Rect region}) async {
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(_currentStory.value.contentUrl),
      size: const Size(400, 400),
      region: region,
    );

    final dominantColor = paletteGenerator.dominantColor?.color;
    if (dominantColor == null) return false;

    return _useWhiteForeground(dominantColor);
  }

  bool _useWhiteForeground(Color backgroundColor) =>
      1.05 / (backgroundColor.computeLuminance() + 0.05) > 4.5;

  void _showOverlayListener() {
    if (!_showOverlay.value) {
      _controller.pause();
    } else {
      if (!_wasVisible.value) return;
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _storyItems.dispose();
    _currentStory.dispose();
    _createdAt.dispose();
    _showOverlay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return Stack(
      children: [
        Viewable(
          itemKey: ValueKey(user.id),
          onSeen: () {
            _wasVisible.value = true;
            if (_controller.playbackNotifier.value == PlaybackState.pause) {
              if (!_wasVisible.value) {
                return;
              }
              if (mounted) _controller.play();
            }
          },
          onUnseen: () {
            if (mounted) _controller.pause();
          },
          child: ValueListenableBuilder(
            valueListenable: _storyItems,
            builder: (context, storyItems, child) {
              return GestureDetector(
                onLongPressStart: (_) => _showOverlay.value = false,
                onLongPressEnd: (_) => _showOverlay.value = true,
                child: StoryView(
                  inline: true,
                  storyItems: storyItems,
                  controller: _controller,
                  onStoryShow: (story, index) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _currentStory.value = _stories[index];
                      _createdAt.value = _stories[index].createdAt;
                      _initColor();
                    });
                    if (props.onStorySeen != null) {
                      props.onStorySeen!.call(index, _stories);
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context
                          .read<StoriesBloc>()
                          .add(StoriesStorySeen(_stories[index], user.id));
                    });
                  },
                  onVerticalSwipeComplete: (_) => context.pop(),
                  onComplete: () {
                    if (context.canPop()) context.pop();
                  },
                ),
              );
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
                author: props.author,
                createdAt: _createdAt.value,
                textColor: _textColor,
              ),
            );
          },
        ),
        Positioned(
          right: AppSpacing.xlg,
          bottom: AppSpacing.xlg,
          child: AnimatedBuilder(
            animation: Listenable.merge([_showOverlay, _currentStory]),
            builder: (context, _) {
              return AnimatedOpacity(
                opacity: _showOverlay.value ? 1 : 0,
                duration: 200.ms,
                child: StoryOptions(
                  controller: _controller,
                  author: props.author,
                  currentStory: _currentStory.value,
                  iconColor: _iconColor,
                  onStoryDeleted: (story) {
                    final storyIndex = _stories.indexOf(story);
                    if (storyIndex == -1) return;
                    if (_storyItems.value.length == 1) {
                      _storyItems.value
                        ..addAll([Story.empty].toStoryItems(_controller))
                        ..removeAt(storyIndex);
                      _currentStory.value = Story.empty;
                      if (context.canPop()) context.pop();
                    } else {
                      _controller.previous();
                      final prevCurrentStoryIndex =
                          _stories.indexOf(_currentStory.value);
                      _stories.removeAt(storyIndex);
                      _storyItems.value.removeAt(storyIndex);
                      final nextStoryIndex = prevCurrentStoryIndex == 0
                          ? 0
                          : prevCurrentStoryIndex - 1;
                      _currentStory.value = _stories.elementAt(nextStoryIndex);
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
    this.iconColor,
    super.key,
  });

  final Story currentStory;
  final StoryController controller;
  final User author;
  final ValueSetter<Story> onStoryDeleted;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = author.id == user.id;

    if (!isMine) return const SizedBox.shrink();

    return Row(
      children: [
        Tappable(
          onTap: () async {
            controller.pause();
            await context.showListOptionsModal(
              options: [
                ModalOption(
                  name: context.l10n.deleteText,
                  actionTitle: context.l10n.deleteStoryText,
                  actionContent: context.l10n.storyDeleteConfirmationText,
                  actionYesText: context.l10n.deleteText,
                  actionNoText: context.l10n.cancelText,
                  icon: Assets.icons.trash.svg(
                    height: AppSize.iconSize,
                    colorFilter:
                        const ColorFilter.mode(AppColors.red, BlendMode.srcIn),
                  ),
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
            ).then((option) {
              if (option == null) {
                controller.play();
                return;
              }
              option.onTap(context);
            });
          },
          child: AnimatedDefaultTextStyle(
            duration: 150.ms,
            style: context.bodyMedium!.copyWith(
              fontWeight: AppFontWeight.bold,
              letterSpacing: 0.4,
              color: iconColor,
            ),
            overflow: TextOverflow.ellipsis,
            child: Column(
              children: [
                Icon(Icons.more_vert_outlined, color: iconColor),
                const Gap.v(AppSpacing.sm),
                Text(context.l10n.moreText),
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
    this.textColor,
    super.key,
  });

  final User author;
  final DateTime? createdAt;
  final Color? textColor;

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
      horizontalTitleGap: AppSpacing.sm,
      leading: UserProfileAvatar(
        isLarge: false,
        avatarUrl: author.avatarUrl,
        userId: author.id,
        onTap: (_) => context.pushNamed(
          'user_profile',
          pathParameters: {'user_id': author.id},
        ),
      ),
      title: AnimatedDefaultTextStyle(
        duration: 150.ms,
        style: context.bodyLarge!.apply(color: textColor),
        overflow: TextOverflow.ellipsis,
        child: Row(
          children: [
            Text.rich(
              TextSpan(
                text: author.displayUsername,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => context.pushNamed(
                        'user_profile',
                        pathParameters: {'user_id': author.id},
                      ),
              ),
            ),
            const Gap.h(AppSpacing.sm),
            if (createdAt != null) Text(createdAt!.timeAgo(context)),
          ],
        ),
      ),
      trailing: isMine
          ? null
          : Tappable(
              onTap: () {},
              child: Icon(Icons.more_vert_outlined, color: textColor),
            ),
    );
  }
}

extension on List<Story> {
  List<StoryItem> toStoryItems(StoryController controller) => safeMap(
        (story) => switch (story.contentType) {
          StoryContentType.image => StoryItem.inlineImage(
              url: story.contentUrl,
              shown: story.seen,
              controller: controller,
              duration: 5.seconds,
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
