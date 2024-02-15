import 'package:app_ui/app_ui.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:firebase_config/firebase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chats.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/network_error/network_error.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, this.initialPage = 1});

  final int initialPage;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with RouteAware {
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
    final videoPlayer = VideoPlayerProvider.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FeedBloc(
            postsRepository: context.read<PostsRepository>(),
            remoteConfig: context.read<FirebaseConfig>(),
          )..add(const FeedPageRequested(page: 0)),
        ),
        BlocProvider(
          create: (context) => StoriesBloc(
            storiesRepository: context.read<StoriesRepository>(),
            userRepository: context.read<UserRepository>(),
          )..add(
              StoriesFetchUserFollowingsStories(
                context.read<AppBloc>().state.user.id,
              ),
            ),
        ),
      ],
      child: PageView(
        controller: videoPlayer.pageController,
        children: const [
          UserProfileCreatePost(),
          FeedView(),
          ChatsPage(),
        ],
      ),
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
    _nestedScrollController = ScrollController();
    _feedScrollController = ScrollController();
    FeedPageController.init(
      nestedController: _nestedScrollController,
      feedController: _feedScrollController,
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
    final animationController = FeedPageController();

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
                  areImmutableCollectionsWithEqualItems(
                    previous.feed.feed.blocks.toIList(),
                    current.feed.feed.blocks.toIList(),
                  )) {
                return false;
              }
              if (previous.status == current.status) return false;
              return true;
            },
            builder: (context, state) {
              final feed = state.feed.feed;
              final hasMorePosts = state.feed.hasMore;
              final isFailure = state.status == FeedStatus.failure;

              return SliverList.builder(
                itemCount: feed.blocks.length,
                itemBuilder: (context, index) {
                  final block = feed.blocks[index];
                  return _buildBlock(
                    context: context,
                    index: index,
                    feedLength: feed.totalBlocks,
                    block: block,
                    bloc: context.read<FeedBloc>(),
                    controller: animationController,
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
    required FeedBloc bloc,
    required FeedPageController controller,
    required bool hasMorePosts,
    required bool isFailure,
  }) {
    if (block is DividerHorizontalBlock) {
      return DividerBlock(feedAnimationController: controller);
    }
    if (block is SectionHeaderBlock) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Text(
                  block.title,
                  style: context.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const AppDivider(),
        ],
      );
    }
    if (index + 1 == feedLength) {
      if (isFailure) {
        if (!hasMorePosts) return const SizedBox.shrink();
        return NetworkError(
          onRetry: () {
            context
                .read<FeedBloc>()
                .add(FeedPageRequested(page: bloc.state.feed.page));
          },
        );
      } else {
        return Padding(
          padding: EdgeInsets.only(
            top: feedLength == 0 ? 12 : 0,
          ),
          child: FeedLoaderItem(
            key: ValueKey(index),
            onPresented: () => hasMorePosts
                ? context.read<FeedBloc>().add(const FeedPageRequested())
                : context
                    .read<FeedBloc>()
                    .add(const FeedRecommenedPostsPageRequested()),
          ),
        );
      }
    }
    if (block is PostBlock) {
      return PostView(
        key: ValueKey(block.id),
        block: block,
        postIndex: index,
      );
    }

    return const Text('Unknown block');
  }
}
