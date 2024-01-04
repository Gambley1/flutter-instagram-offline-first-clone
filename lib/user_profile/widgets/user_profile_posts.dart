import 'dart:convert';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/comments/view/view.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class UserProfilePosts extends StatefulWidget {
  const UserProfilePosts({
    required this.userId,
    required this.index,
    super.key,
  });

  final String userId;
  final int index;

  @override
  State<UserProfilePosts> createState() => _UserProfilePostsState();
}

class _UserProfilePostsState extends State<UserProfilePosts> {
  late ItemScrollController _itemScrollController;
  late ItemPositionsListener _itemPositionsListener;
  late ScrollOffsetController _scrollOffsetController;
  late ScrollOffsetListener _scrollOffsetListener;

  @override
  void initState() {
    super.initState();
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _scrollOffsetController = ScrollOffsetController();
    _scrollOffsetListener = ScrollOffsetListener.create();
  }

  /// Handles actions triggered by tapping on feedBloc items.
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

  @override
  Widget build(BuildContext context) {
    final userBloc = context.read<UserProfileBloc>();
    final feedBloc = context.read<FeedBloc>();

    final user = context.select((AppBloc bloc) => bloc.state.user);

    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          UserProfilePostsAppBar(userId: widget.userId),
          StreamBuilder<List<PostBlock>>(
            stream: context.read<UserProfileBloc>().userPosts(),
            builder: (context, snapshot) {
              final blocks = snapshot.data;

              return PostsListView(
                enableFollowButton: false,
                withItemController: true,
                blocks: blocks,
                isLiked: userBloc.isLiked,
                withLoading: false,
                likesCount: userBloc.likesCount,
                likePost: (id) =>
                    userBloc.add(UserProfileLikePostRequested(id)),
                isFollowed: (id) =>
                    context.read<UserProfileBloc>().followingStatus(userId: id),
                follow: (id) => context
                    .read<UserProfileBloc>()
                    .add(UserProfileFollowUserRequested(id)),
                likesText: context.l10n.likesCountText,
                commentsText: context.l10n.seeAllComments,
                commentsCountOf: feedBloc.commentsCountOf,
                timeAgo: (publishedAt) => publishedAt.timeAgo(context),
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                scrollOffsetController: _scrollOffsetController,
                scrollOffsetListener: _scrollOffsetListener,
                index: widget.index,
                isOwner: userBloc.isOwnerOfPostBy,
                onPressed: (action) => _onFeedItemAction(context, action),
                onCommentsTap: (block, showFullSized) => _onCommentsTap(
                  post: block,
                  bloc: feedBloc,
                  context: context,
                  showFullSized: showFullSized,
                ),
                onPostShareTap: (postId, author) async {
                  final receiverId = await context.pushNamed(
                    'search_users',
                    extra: true,
                  ) as String?;
                  if (receiverId == null) return;
                  final receiver = User.fromRow(
                    jsonDecode(receiverId) as Map<String, dynamic>,
                  );
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class UserProfilePostsAppBar extends StatelessWidget {
  const UserProfilePostsAppBar({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserProfileBloc>();
    final isOwner = context.select<UserProfileBloc, bool>((b) => b.isOwner);
    return SliverAppBar(
      centerTitle: false,
      pinned: true,
      scrolledUnderElevation: 0,
      actions: [
        StreamBuilder<bool>(
          stream: bloc.followingStatus(userId: userId),
          builder: (context, snapshot) {
            final isSubscribed = snapshot.data;
            if (isSubscribed == null) return const SizedBox.shrink();
            if (isOwner) return const SizedBox.shrink();

            final subscribeText = Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Tappable(
                onTap: isSubscribed
                    ? null
                    : () => bloc.add(UserProfileFollowUserRequested(userId)),
                child: Text(
                  'Subscribe',
                  style: context.titleLarge?.copyWith(
                    color: Colors.blue.shade500,
                  ),
                ),
              ),
            );
            return AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              duration: const Duration(milliseconds: 550),
              child: isSubscribed ? const SizedBox.shrink() : subscribeText,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.3, 1),
                  ),
                  child: child,
                );
              },
            );
          },
        ),
      ],
      title: const Text('Publications'),
    );
  }
}
