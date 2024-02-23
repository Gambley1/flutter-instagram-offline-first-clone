import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared/shared.dart';

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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: InViewNotifierCustomScrollView(
        cacheExtent: 2760,
        initialInViewIds: [widget.index.toString()],
        isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) {
          return deltaTop < (0.5 * vpHeight) + 80.0 &&
              deltaBottom > (0.5 * vpHeight) - 80.0;
        },
        slivers: [
          UserProfilePostsAppBar(userId: widget.userId),
          StreamBuilder<List<PostBlock>>(
            stream: context
                .read<UserProfileBloc>()
                .userPosts(userId: widget.userId, small: false),
            builder: (context, snapshot) {
              final blocks = snapshot.data;

              return PostsListView(
                postBuilder: (_, index, block) => PostView(
                  key: ValueKey(block.id),
                  block: block,
                  postIndex: index,
                  withCustomVideoPlayer: false,
                ),
                withItemController: true,
                blocks: blocks,
                withLoading: false,
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                scrollOffsetController: _scrollOffsetController,
                scrollOffsetListener: _scrollOffsetListener,
                index: widget.index,
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
      actions: [
        BetterStreamBuilder<bool>(
          stream: bloc.followingStatus(userId: userId),
          builder: (context, isFollowed) {
            if (isFollowed) return const SizedBox.shrink();
            if (isOwner) return const SizedBox.shrink();

            final followText = Padding(
              padding:
                  const EdgeInsets.only(right: AppSpacing.lg),
              child: Tappable(
                onTap: isFollowed
                    ? null
                    : () => bloc.add(UserProfileFollowUserRequested(userId)),
                child: Text(
                  context.l10n.followUser,
                  style: context.titleLarge?.copyWith(
                    color: AppColors.blue,
                  ),
                ),
              ),
            );
            return AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              duration: 550.ms,
              child: isFollowed ? const SizedBox.shrink() : followText,
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
      title: Text(context.l10n.profilePostsAppBarTitle),
    );
  }
}
