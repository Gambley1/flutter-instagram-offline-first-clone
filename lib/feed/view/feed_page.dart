import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/network_error/network_error.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, this.initialPage = 1});

  final int initialPage;

  @override
  State<FeedPage> createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> with RouteAware {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialPage);
    context
        .read<UserProfileBloc>()
        .add(const UserProfileFetchFollowingsRequested());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoriesBloc(
        storiesRepository: context.read<StoriesRepository>(),
        userRepository: context.read<UserRepository>(),
      )..add(
          StoriesFetchUserFollowingsStories(
            context.read<AppBloc>().state.user.id,
          ),
        ),
      child: const FeedView(),
    );
  }
}

/// {@template feed_view}
/// The main FeedView widget that builds the UI for the feed screen.
/// {@endtemplate}
class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late ScrollController _nestedScrollController;
  late ScrollController _feedScrollController;

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const FeedPageRequested(page: 0));

    _nestedScrollController = ScrollController();
    _feedScrollController = ScrollController();
    FeedPageController().init(
      nestedController: _nestedScrollController,
      feedController: _feedScrollController,
      context: context,
    );
  }

  @override
  void dispose() {
    _nestedScrollController.dispose();
    _feedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        controller: _nestedScrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: FeedAppBar(innerBoxIsScrolled: innerBoxIsScrolled),
            ),
          ];
        },
        body: FeedBody(controller: _feedScrollController),
      ),
    );
  }
}

class FeedBody extends StatefulWidget {
  const FeedBody({required this.controller, super.key});

  final ScrollController controller;

  @override
  State<FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<FeedBody> {
  @override
  Widget build(BuildContext context) {
    final feedPageController = FeedPageController();

    return RefreshIndicator.adaptive(
      onRefresh: () async => Future.wait([
        Future.microtask(
          () => context.read<FeedBloc>().add(const FeedRefreshRequested()),
        ),
        Future.microtask(
          () => context.read<StoriesBloc>().add(
                StoriesFetchUserFollowingsStories(
                  context.read<AppBloc>().state.user.id,
                ),
              ),
        ),
      ]),
      child: InViewNotifierCustomScrollView(
        cacheExtent: 2760,
        initialInViewIds: const ['0'],
        isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) {
          return deltaTop < (0.5 * vpHeight) + 80.0 &&
              deltaBottom > (0.5 * vpHeight) - 80.0;
        },
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          const StoriesCarousel(),
          const AppSliverDivider(),
          BlocBuilder<FeedBloc, FeedState>(
            buildWhen: (previous, current) {
              if (previous.status == FeedStatus.populated &&
                  const ListEquality<InstaBlock>().equals(
                    previous.feed.feedPage.blocks,
                    current.feed.feedPage.blocks,
                  )) {
                return false;
              }
              if (previous.status == current.status) return false;
              return true;
            },
            builder: (context, state) {
              final feedPage = state.feed.feedPage;
              final hasMorePosts = feedPage.hasMore;
              final isFailure = state.status == FeedStatus.failure;

              return SliverList.builder(
                itemCount: feedPage.blocks.length,
                itemBuilder: (context, index) {
                  final block = feedPage.blocks[index];
                  return _buildBlock(
                    context: context,
                    index: index,
                    feedLength: feedPage.totalBlocks,
                    block: block,
                    feedPageController: feedPageController,
                    hasMorePosts: hasMorePosts,
                    isFailure: isFailure,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlock({
    required BuildContext context,
    required int index,
    required int feedLength,
    required InstaBlock block,
    required FeedPageController feedPageController,
    required bool hasMorePosts,
    required bool isFailure,
  }) {
    if (block is DividerHorizontalBlock) {
      return DividerBlock(feedPageController: feedPageController);
    }
    if (block is SectionHeaderBlock) {
      return switch (block.sectionType) {
        SectionHeaderBlockType.suggested => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  context.l10n.suggestedForYouText,
                  style: context.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const AppDivider(),
            ],
          ),
      };
    }
    if (index + 1 == feedLength) {
      if (isFailure) {
        if (!hasMorePosts) return const SizedBox.shrink();
        return NetworkError(
          onRetry: () {
            context.read<FeedBloc>().add(const FeedPageRequested());
          },
        );
      } else {
        return Padding(
          padding: EdgeInsets.only(top: feedLength == 0 ? AppSpacing.md : 0),
          child: FeedLoaderItem(
            key: ValueKey(index),
            onPresented: () => hasMorePosts
                ? context.read<FeedBloc>().add(const FeedPageRequested())
                : context
                    .read<FeedBloc>()
                    .add(const FeedRecommendedPostsPageRequested()),
          ),
        );
      }
    }
    if (block is PostBlock) {
      return PostView(key: ValueKey(block.id), block: block, postIndex: index);
    }

    return Text('Unknown block type: ${block.type}');
  }
}
