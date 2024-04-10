import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/video/video.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reel/reel.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReelsView();
  }
}

class ReelsView extends StatefulWidget {
  const ReelsView({super.key});

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> {
  late PageController _pageController;

  late ValueNotifier<int> _currentIndex;

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const FeedReelsPageRequested());
    _pageController = PageController(keepPage: false);

    _currentIndex = ValueNotifier(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayerProvider =
        VideoPlayerInheritedWidget.of(context).videoPlayerProvider;

    return Stack(
      fit: StackFit.expand,
      children: [
        AppScaffold(
          body: BlocBuilder<FeedBloc, FeedState>(
            buildWhen: (previous, current) {
              if (const ListEquality<InstaBlock>().equals(
                previous.feed.reelsPage.blocks,
                current.feed.reelsPage.blocks,
              )) {
                return false;
              }
              if (previous.status == current.status) return false;
              return true;
            },
            builder: (context, state) {
              final blocks = state.feed.reelsPage.blocks;

              if (blocks.isEmpty) {
                return const NoReelsFound();
              }
              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context.read<FeedBloc>().add(const FeedReelsPageRequested());
                  unawaited(
                    _pageController.animateToPage(
                      0,
                      duration: 150.ms,
                      curve: Curves.easeIn,
                    ),
                  );
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: blocks.length,
                  allowImplicitScrolling: true,
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  onPageChanged: (index) => _currentIndex.value = index,
                  itemBuilder: (context, index) {
                    return ListenableBuilder(
                      listenable: Listenable.merge(
                        [
                          videoPlayerProvider.shouldPlayReels,
                          videoPlayerProvider.withSound,
                          _currentIndex,
                        ],
                      ),
                      builder: (context, _) {
                        final isCurrent = index == _currentIndex.value;
                        final block = blocks[index];
                        if (block is PostReelBlock) {
                          return ReelView(
                            key: ValueKey(block.id),
                            play: isCurrent &&
                                videoPlayerProvider.shouldPlayReels.value,
                            withSound: videoPlayerProvider.withSound.value,
                            block: block,
                          );
                        }
                        return Center(
                          child: Text('Unknown block type: ${block.type}'),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          right: AppSpacing.md,
          top: AppSpacing.md,
          child: Tappable(
            onTap: () => PickImage().pickVideo(
              context,
              onMediaPicked: (_, details) => context.pushNamed(
                'publish_post',
                extra: CreatePostProps(
                  details: details,
                  isReel: true,
                ),
              ),
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              size: AppSize.iconSize,
              color: context.adaptiveColor,
            ),
          ),
        ),
      ],
    );
  }
}

class NoReelsFound extends StatelessWidget {
  const NoReelsFound({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Center(
        child: EmptyPosts(
          isSliver: false,
          text: context.l10n.noReelsFoundText,
          icon: Icons.video_collection_outlined,
          child: FittedBox(
            child: Tappable(
              onTap: () =>
                  context.read<FeedBloc>().add(const FeedReelsPageRequested()),
              throttle: true,
              throttleDuration: 550.ms,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(22),
                  ),
                  color: context.customReversedAdaptiveColor(
                    light: context.theme.focusColor,
                    dark: context.theme.focusColor,
                  ),
                ),
                child: Align(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.refresh),
                        Text(
                          context.l10n.refreshText,
                          style: context.labelLarge,
                        ),
                      ].spacerBetween(width: AppSpacing.md),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
