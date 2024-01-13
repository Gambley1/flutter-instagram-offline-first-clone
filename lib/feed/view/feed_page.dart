import 'dart:convert';

import 'package:app_ui/app_ui.dart';
import 'package:firebase_config/firebase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chats.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comments.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/network_error/network_error.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
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

class _FeedPageState extends State<FeedPage> {
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FeedBloc(
            userRepository: context.read<UserRepository>(),
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
        controller: _controller,
        allowImplicitScrolling: true,
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

class FeedBody extends StatelessWidget {
  const FeedBody({required this.controller, super.key});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final animationController = FeedPageController();

    final feed = context.select((FeedBloc b) => b.state.feed.feed);
    final hasMorePosts = context.select((FeedBloc b) => b.state.feed.hasMore);
    final isFailure = context
        .select((FeedBloc bloc) => bloc.state.status == FeedStatus.failure);

    final user = context.select((AppBloc bloc) => bloc.state.user);

    return RefreshIndicator.adaptive(
      onRefresh: () async => Future.wait([
        Future(
          () => context.read<FeedBloc>().add(const FeedRefreshRequested()),
        ),
        Future(
          () => context
              .read<StoriesBloc>()
              .add(StoriesFetchUserFollowingsStories(user.id)),
        ),
      ]),
      child: CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          const StoriesCarousel(),
          const AppSliverDivider(),
          SliverList.builder(
            itemCount: feed.blocks.length,
            itemBuilder: (context, index) {
              final block = feed.blocks[index];
              return _buildSliverItem(
                context: context,
                index: index,
                feedLength: feed.totalBlocks,
                block: block,
                bloc: context.read<FeedBloc>(),
                user: user,
                controller: animationController,
                hasMorePosts: hasMorePosts,
                isFailure: isFailure,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverItem({
    required BuildContext context,
    required int index,
    required int feedLength,
    required InstaBlock block,
    required FeedBloc bloc,
    required FeedPageController controller,
    required User user,
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
        return hasMorePosts
            ? Padding(
                padding: EdgeInsets.only(
                  top: feedLength == 0 ? 12 : 0,
                ),
                child: FeedLoaderItem(
                  key: ValueKey(index),
                  onPresented: () =>
                      context.read<FeedBloc>().add(const FeedPageRequested()),
                ),
              )
            : const SizedBox();
      }
    }
    if (block is PostLargeBlock) {
      return PostLarge(
        block: block,
        isOwner: bloc.isOwnerOfPostBy(block.author.id),
        hasStories: false,
        imagesUrl: block.imagesUrl,
        isLiked: bloc.isLiked(block.id),
        likePost: () => bloc.add(FeedLikePostRequested(block.id)),
        likesCount: bloc.likesCount(block.id),
        publishedAt: block.publishedAt.timeAgo(context),
        isFollowed: bloc.followingStatus(userId: block.author.id),
        wasFollowed: true,
        follow: () => bloc.add(FeedPostAuthorFollowRequested(block.author.id)),
        enableFollowButton: true,
        onCommentsTap: (showFullSized) => _onCommentsTap(
          context: context,
          post: block,
          bloc: bloc,
          showFullSized: showFullSized,
        ),
        commentsCount: bloc.commentsCountOf(block.id),
        likesText: context.l10n.likesCountText,
        commentsText: context.l10n.seeAllComments,
        onPressed: (action, _) => _onFeedItemAction(context, action),
        onPostShareTap: (postId, author) async {
          final receiverId =
              await context.pushNamed('search_users', extra: true) as String?;
          if (receiverId == null) return;
          final receiver =
              User.fromJson(jsonDecode(receiverId) as Map<String, dynamic>);
          await Future(
            () => context.read<FeedBloc>().add(
                  FeedPostShareRequested(
                    postId: postId,
                    sender: user,
                    receiver: receiver,
                    postAuthor: author,
                    message: Message(id: UidGenerator.v4()),
                  ),
                ),
          );
        },
        postAuthorAvatarBuilder: (context, author, onAvatarTap) {
          return UserStoriesAvatar(
            author: author.toUser,
            onAvatarTap: onAvatarTap,
            enableUnactiveBorder: false,
          );
        },
      );
    }
    if (block is PostSponsoredBlock) {
      return PostSponsored(
        block: block,
        isOwner: bloc.isOwnerOfPostBy(block.author.id),
        hasStories: false,
        imagesUrl: block.imagesUrl,
        isLiked: bloc.isLiked(block.id),
        likePost: () => bloc.add(FeedLikePostRequested(block.id)),
        likesCount: bloc.likesCount(block.id),
        publishedAt: block.publishedAt.timeAgo(context),
        isFollowed: bloc.followingStatus(userId: block.author.id),
        wasFollowed: true,
        follow: () => bloc.add(FeedPostAuthorFollowRequested(block.author.id)),
        enableFollowButton: true,
        onCommentsTap: (showFullSized) => _onCommentsTap(
          context: context,
          post: block,
          bloc: bloc,
          showFullSized: showFullSized,
        ),
        likesText: context.l10n.likesCountText,
        commentsText: context.l10n.seeAllComments,
        onPressed: (action, _) => _onFeedItemAction(context, action),
        commentsCount: bloc.commentsCountOf(block.id),
        sponsoredText: context.l10n.sponsoredPostText,
        onPostShareTap: (postId, author) async {
          final receiverId =
              await context.pushNamed('search_users', extra: true) as String?;
          if (receiverId == null) return;
          final receiver =
              User.fromJson(jsonDecode(receiverId) as Map<String, dynamic>);
          await Future(
            () => context.read<FeedBloc>().add(
                  FeedPostShareRequested(
                    postId: postId,
                    sender: user,
                    receiver: receiver,
                    postAuthor: author,
                    message: Message(id: UidGenerator.v4()),
                  ),
                ),
          );
        },
        postAuthorAvatarBuilder: (context, author, onAvatarTap) {
          return UserStoriesAvatar(
            author: author.toUser,
            onAvatarTap: onAvatarTap,
            enableUnactiveBorder: false,
          );
        },
      );
    }

    return const Text('Unknown block');
  }

  Future<void> _onCommentsTap({
    required PostBlock post,
    required FeedBloc bloc,
    required BuildContext context,
    bool showFullSized = false,
  }) =>
      context.showBottomModal<void>(
        isScrollControlled: true,
        enalbeDrag: false,
        showDragHandle: false,
        builder: (context) {
          final controller = DraggableScrollableController();
          return DraggableScrollableSheet(
            controller: controller,
            expand: false,
            snap: true,
            snapSizes: const [
              .6,
              1,
            ],
            initialChildSize: showFullSized ? 1.0 : .7,
            minChildSize: .4,
            builder: (context, scrollController) => CommentsPage(
              bloc: bloc,
              post: post,
              scrollController: scrollController,
              scrollableSheetController: controller,
            ),
          );
        },
      );

  /// Handles actions triggered by tapping on feed items.
  void _onFeedItemAction(
    BuildContext context,
    BlockAction action,
  ) =>
      action.when(
        navigateToPostAuthor: (action) => context.pushNamed(
          'user_profile',
          pathParameters: {'user_id': action.authorId},
        ),
        navigateToSponsoredPostAuthor: (action) => context.pushNamed(
          'user_profile',
          queryParameters: {'promo_action': jsonEncode(action.toJson())},
          pathParameters: {'user_id': action.authorId},
          extra: true,
        ),
      );
}
