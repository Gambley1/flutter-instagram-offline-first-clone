import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reel/reel.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reels.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReelsBloc(
        postsRepository: context.read<PostsRepository>(),
      )..add(const ReelsPageRequested()),
      child: const ReelsView(),
    );
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
    final videoPlayer = VideoPlayerProvider.of(context).videoPlayerState;

    return Stack(
      fit: StackFit.expand,
      children: [
        AppScaffold(
          body: BlocBuilder<ReelsBloc, ReelsState>(
            buildWhen: (previous, current) {
              if (const ListEquality<PostBlock>()
                  .equals(previous.blocks, current.blocks)) {
                return false;
              }
              if (previous.status == current.status) return false;
              return true;
            },
            builder: (context, state) {
              final blocks = state.blocks;
              if (blocks.isEmpty) {
                return const NoReelsFound();
              }
              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context.read<ReelsBloc>().add(const ReelsPageRequested());
                  unawaited(
                    _pageController.animateToPage(
                      0,
                      duration: 150.ms,
                      curve: Curves.easeIn,
                    ),
                  );
                },
                child: PageView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  allowImplicitScrolling: true,
                  itemCount: blocks.length,
                  onPageChanged: (index) => _currentIndex.value = index,
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: Listenable.merge(
                        [
                          videoPlayer.shouldPlayReels,
                          videoPlayer.withSound,
                          _currentIndex,
                        ],
                      ),
                      builder: (context, _) {
                        final isCurrent = index == _currentIndex.value;
                        final block = blocks[index];
                        return ReelView(
                          key: ValueKey(block.id),
                          play: isCurrent && videoPlayer.shouldPlayReels.value,
                          withSound: videoPlayer.withSound.value,
                          block: block,
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
              onMediaPicked: (context, details) => context.pushNamed(
                'publish_post',
                extra: CreatePostProps(
                  details: details,
                  isReel: true,
                  context: context,
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
  const NoReelsFound({
    super.key,
  });

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
                  context.read<ReelsBloc>().add(const ReelsPageRequested()),
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
                      ].insertBetween(
                        const SizedBox(width: AppSpacing.md),
                      ),
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
