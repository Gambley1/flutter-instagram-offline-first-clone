import 'dart:convert';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/comments/view/view.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class PostPreviewPage extends StatelessWidget {
  const PostPreviewPage({
    required this.id,
    super.key,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedBloc(
        postsRepository: context.read<PostsRepository>(),
        userRepository: context.read<UserRepository>(),
      ),
      child: AppScaffold(
        appBar: const PostPreviewAppBar(),
        body: PostPreviewDetails(id: id),
      ),
    );
  }
}

class PostPreviewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PostPreviewAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:
          Assets.images.instagramTextLogo.svg(color: Colors.white, width: 120),
      centerTitle: false,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PostPreviewEmptyDetails extends StatelessWidget {
  const PostPreviewEmptyDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No post found!',
        style: context.headlineMedium?.copyWith(fontWeight: AppFontWeight.bold),
      ),
    );
  }
}

class PostPreviewDetails extends StatefulWidget {
  const PostPreviewDetails({required this.id, super.key});

  final String id;

  @override
  State<PostPreviewDetails> createState() => _PostPreviewDetailsState();
}

class _PostPreviewDetailsState extends State<PostPreviewDetails> {
  PostBlock? block;

  @override
  void initState() {
    super.initState();
    context
        .read<FeedBloc>()
        .getPostBy(widget.id)
        .then((value) => setState(() => block = value));
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
          'user_profile_root',
          pathParameters: {'user_id': action.authorId},
        ),
        navigateToSponsoredPostAuthor: (action) => context.pushNamed(
          'user_profile_root',
          queryParameters: {'promo_action': jsonEncode(action.toJson())},
          pathParameters: {'user_id': action.authorId},
          extra: true,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FeedBloc>();
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return RefreshIndicator.adaptive(
      onRefresh: () async => bloc
          .getPostBy(widget.id)
          .then((value) => setState(() => block = value)),
      child: ListView(
        children: [
          if (block == null)
            const PostPreviewEmptyDetails()
          else
            PostLarge(
              block: block!,
              isOwner: bloc.isOwnerOfPostBy(block!.author.id),
              hasStories: false,
              imagesUrl: block!.imagesUrl,
              isLiked: bloc.isLiked(block!.id),
              likePost: () => bloc.add(FeedLikePostRequested(block!.id)),
              likesCount: bloc.likesCount(block!.id),
              publishedAt: block!.publishedAt.timeAgo(context),
              isFollowed: bloc.followingStatus(userId: block!.author.id),
              wasFollowed: true,
              follow: () =>
                  bloc.add(FeedPostAuthorFollowRequested(block!.author.id)),
              enableFollowButton: true,
              onCommentsTap: (showFullSized) => _onCommentsTap(
                context: context,
                post: block!,
                bloc: bloc,
                showFullSized: showFullSized,
              ),
              commentsCount: bloc.commentsCountOf(block!.id),
              likesText: context.l10n.likesCountText,
              commentsText: context.l10n.seeAllComments,
              onPressed: (action) => _onFeedItemAction(context, action),
              onPostShareTap: (postId) async {
                final userId =
                    await context.pushNamed('search_users') as String?;
                if (userId == null) return;
                await Future(
                  () => context.read<FeedBloc>().add(
                        FeedPostShareRequested(
                          postId: postId,
                          senderUserId: user.id,
                          recipientUserId: userId,
                          message: Message(id: UidGenerator.v4()),
                        ),
                      ),
                );
              },
            ),
        ],
      ),
    );
  }
}
