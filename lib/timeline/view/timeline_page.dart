import 'package:app_ui/app_ui.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/search/view/search_view.dart';
import 'package:flutter_instagram_offline_first_clone/timeline/timeline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimelineBloc(
        postsRepository: context.read<PostsRepository>(),
      )..add(const TimelinePageRequested()),
      child: const TimelineView(),
    );
  }
}

class TimelineView extends StatelessWidget {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      body: RefreshIndicator.adaptive(
        onRefresh: () async =>
            context.read<TimelineBloc>().add(const TimelineRefreshRequested()),
        child: InViewNotifierCustomScrollView(
          cacheExtent: 2760,
          initialInViewIds: const ['2', '5'],
          isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) =>
              deltaTop < (0.5 * vpHeight) + 220.0 &&
              deltaBottom > (0.5 * vpHeight) - 220.0,
          slivers: [
            const SliverAppBar(
              title: SearchInputField(
                active: true,
                readOnly: true,
              ),
              floating: true,
              toolbarHeight: 64,
            ),
            BlocBuilder<TimelineBloc, TimelineState>(
              buildWhen: (previous, current) {
                // if (previous.timeline.feed.blocks.isEmpty &&
                //     current.timeline.feed.blocks.isEmpty) return false;
                if (previous.status == TimelineStatus.populated &&
                    areImmutableCollectionsWithEqualItems(
                      previous.timeline.feed.blocks.toIList(),
                      current.timeline.feed.blocks.toIList(),
                    )) {
                  return false;
                }
                if (previous.status != current.status) return true;

                return true;
              },
              builder: (context, state) {
                if (state.status == TimelineStatus.failure) {
                  return const TimelineError();
                }
                if (state.status == TimelineStatus.populated) {
                  final imageBlocks = <PostBlock>[];
                  final videoBlocks = <PostBlock>[];

                  for (final block
                      in state.timeline.feed.blocks.cast<PostBlock>()) {
                    final isImage = block.hasBothMediaTypes || !block.isReel;
                    if (isImage) {
                      imageBlocks.add(block);
                    } else {
                      videoBlocks.add(block);
                    }
                  }

                  final blocksLength = imageBlocks.length + videoBlocks.length;

                  return TimelineGridView(
                    imageBlocks: imageBlocks,
                    videoBlocks: videoBlocks,
                    blocksLength: blocksLength,
                  );
                } else {
                  return const TimelineLoading();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineGridView extends StatefulWidget {
  const TimelineGridView({
    required this.imageBlocks,
    required this.videoBlocks,
    required this.blocksLength,
    super.key,
  });

  final List<PostBlock> imageBlocks;
  final List<PostBlock> videoBlocks;
  final int blocksLength;

  @override
  State<TimelineGridView> createState() => _TimelineGridViewState();
}

class _TimelineGridViewState extends State<TimelineGridView> {
  var _videosIndex = 0;
  var _imagesIndex = 0;

  var _displayVideo = false;

  late PostBlock _block;

  void _structurePostDisplay(int index) {
    if (_videosIndex >= widget.videoBlocks.length &&
        _imagesIndex < widget.imageBlocks.length) {
      _block = widget.imageBlocks[_imagesIndex];
      _imagesIndex++;
    } else if (_videosIndex < widget.videoBlocks.length &&
        _imagesIndex >= widget.imageBlocks.length) {
      _block = widget.videoBlocks[_videosIndex];
      _videosIndex++;
    } else {
      if (_videosIndex >= widget.videoBlocks.length &&
          _imagesIndex >= widget.imageBlocks.length) {
        _videosIndex = 0;
        _imagesIndex = 0;
      }

      if (index == 2) {
        _displayVideo = true;
      } else if (index % 5 == 0 && index != 0) {
        _displayVideo = !_displayVideo;
      } else if (index % 11 == 0 && index != 0) {
        _displayVideo = true;
      } else {
        _displayVideo = false;
      }

      if (_displayVideo && _videosIndex < widget.videoBlocks.length) {
        _block = widget.videoBlocks[_videosIndex];
        _videosIndex++;
      } else {
        _block = widget.imageBlocks[_imagesIndex];
        _imagesIndex++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppBloc>().state.user;

    return SliverGrid.builder(
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        repeatPattern: QuiltedGridRepeatPattern.inverted,
        pattern: [
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(2, 1),
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(1, 1),
        ],
      ),
      itemCount: widget.blocksLength,
      itemBuilder: (context, index) {
        _structurePostDisplay(index);
        final multiMedia = _block.media.length > 1;
        final isOwner = _block.author.id == user.id;

        return PostPopup(
          key: ValueKey(_block.id),
          block: _block,
          index: index,
          showComments: false,
          builder: (_) => PostSmall(
            isOwner: isOwner,
            pinned: false,
            isReel: _block.isReel,
            multiMedia: multiMedia,
            mediaUrl: _block.firstMediaUrl!,
            imageThumbnailBuilder: (_, url) => _block.isReel
                ? VideoPlayerNotifierWidget(
                    type: VideoPlayerType.timeline,
                    id: '$index',
                    checkIsInView: true,
                    builder: (context, shouldPlay, child) {
                      return VideoPlay(
                        url: _block.firstMedia!.url,
                        play: shouldPlay,
                        withSound: false,
                        expand: true,
                        blurHash: _block.firstMedia!.blurHash,
                        withSoundButton: false,
                        withPlayControll: false,
                        videoPlayerOptions: VideoPlayerOptions(
                          mixWithOthers: true,
                        ),
                        initDelay: 250.ms,
                      );
                    },
                  )
                : ImageAttachmentThumbnail(
                    image: Attachment(imageUrl: url),
                    fit: BoxFit.cover,
                  ),
          ),
        );
      },
    );
  }
}

class TimelineLoading extends StatelessWidget {
  const TimelineLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        repeatPattern: QuiltedGridRepeatPattern.inverted,
        pattern: [
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(2, 1),
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(1, 1),
        ],
      ),
      itemCount: 20,
      itemBuilder: (_, __) => const ShimmerPlaceholder(),
    );
  }
}

class TimelineError extends StatelessWidget {
  const TimelineError({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Something went wrong!',
            style: context.headlineSmall,
          ),
          FittedBox(
            child: Tappable(
              onTap: () => context
                  .read<TimelineBloc>()
                  .add(const TimelinePageRequested()),
              throttle: true,
              throttleDuration: 880.ms,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(22)),
                  border: Border.all(color: context.adaptiveColor),
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
                          'Try again',
                          style: context.labelLarge,
                        ),
                      ].insertBetween(const SizedBox(width: AppSpacing.md)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ].insertBetween(const SizedBox(height: AppSpacing.sm)),
      ),
    );
  }
}
