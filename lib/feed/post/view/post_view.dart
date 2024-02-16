import 'dart:convert';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comments.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/slang/translations.g.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class PostView extends StatelessWidget {
  const PostView({
    required this.block,
    this.builder,
    this.postIndex,
    this.withInViewNotifier = true,
    this.withCustomVideoPlayer = true,
    this.videoPlayerType = VideoPlayerType.feed,
    super.key,
  });

  final PostBlock block;
  final WidgetBuilder? builder;
  final int? postIndex;
  final bool withInViewNotifier;
  final bool withCustomVideoPlayer;
  final VideoPlayerType videoPlayerType;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return BlocProvider(
      create: (context) => PostBloc(
        postId: block.id,
        userRepository: context.read<UserRepository>(),
        postsRepository: context.read<PostsRepository>(),
      )
        ..add(const PostLikesCountSubscriptionRequested())
        ..add(const PostCommentsCountSubscriptionRequested())
        ..add(PostIsLikedSubscriptionRequested(user.id))
        ..add(
          PostAuthoFollowingStatusSubscriptionRequested(
            ownerId: block.author.id,
            currentUserId: user.id,
          ),
        ),
      child: builder?.call(context) ??
          PostLargeView(
            block: block,
            postIndex: postIndex,
            withInViewNotifier: withInViewNotifier,
            withCustomVideoPlayer: withCustomVideoPlayer,
            videoPlayerType: videoPlayerType,
          ),
    );
  }
}

class PostLargeView extends StatelessWidget {
  const PostLargeView({
    required this.block,
    required this.postIndex,
    required this.withInViewNotifier,
    required this.withCustomVideoPlayer,
    required this.videoPlayerType,
    super.key,
  });

  final PostBlock block;
  final int? postIndex;
  final bool withInViewNotifier;
  final bool withCustomVideoPlayer;
  final VideoPlayerType videoPlayerType;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PostBloc>();
    final user = context.select((AppBloc bloc) => bloc.state.user);

    final isOwner = context.select((PostBloc bloc) => bloc.state.isOwner);
    final isLiked = context.select((PostBloc bloc) => bloc.state.isLiked);
    final likesCount = context.select((PostBloc bloc) => bloc.state.likes);
    final isFollowed = context.select((PostBloc bloc) => bloc.state.isFollowed);
    final commentsCount =
        context.select((PostBloc bloc) => bloc.state.commentsCount);

    final t = context.t;
    final l10n = context.l10n;

    if (block is PostSponsoredBlock) {
      return PostSponsored(
        key: ValueKey(block.id),
        block: block as PostSponsoredBlock,
        isOwner: isOwner,
        isLiked: isLiked,
        likePost: () => bloc.add(PostLikeRequested(user.id)),
        likesCount: likesCount,
        createdAt: block.createdAt.timeAgo(context),
        isFollowed: isOwner || (isFollowed ?? false),
        wasFollowed: true,
        follow: () => bloc.add(
          PostAuthorFollowRequested(
            authorId: block.author.id,
            currentUserId: user.id,
          ),
        ),
        enableFollowButton: true,
        onCommentsTap: (showFullSized) => context.showScrollableModal(
          showFullSized: showFullSized,
          pageBuilder: (scrollController, draggableScrollController) =>
              CommentsPage(
            post: block,
            scrollController: scrollController,
            draggableScrollController: draggableScrollController,
          ),
        ),
        postIndex: postIndex,
        withInViewNotifier: withInViewNotifier,
        sponsoredText: context.l10n.sponsoredPostText,
        commentsCount: commentsCount,
        likesText: l10n.likesCountText,
        commentsText: l10n.seeAllComments,
        postAuthorAvatarBuilder: (context, author, onAvatarTap) {
          return UserStoriesAvatar(
            author: author.toUser,
            onAvatarTap: onAvatarTap,
            enableUnactiveBorder: false,
            withAdaptiveBorder: false,
          );
        },
        postOptionsSettings: const PostOptionsSettings.viewer(),
        onPressed: (action, _) => action?.when(
          navigateToPostAuthor: (action) => context.pushNamed(
            'user_profile',
            pathParameters: {'user_id': action.authorId},
          ),
          navigateToSponsoredPostAuthor: (action) => context.pushNamed(
            'user_profile',
            pathParameters: {'user_id': action.authorId},
            queryParameters: {
              'promo_action': json.encode(action.toJson()),
            },
            extra: true,
          ),
        ),
        onPostShareTap: (postId, author) => context.showScrollableModal(
          pageBuilder: (scrollController, draggableScrollController) =>
              SharePost(
            block: block,
            scrollController: scrollController,
            draggableScrollController: draggableScrollController,
          ),
        ),
        videoPlayerBuilder: !withCustomVideoPlayer
            ? null
            : (_, media, aspectRatio, isInView) {
                final videoPlayer =
                    VideoPlayerProvider.of(context).videoPlayerState;

                return VideoPlayerNotifierWidget(
                  type: videoPlayerType,
                  builder: (context, shouldPlay, child) {
                    final play = shouldPlay && isInView;
                    return ValueListenableBuilder(
                      valueListenable: videoPlayer.withSound,
                      builder: (context, withSound, child) {
                        return VideoPlay(
                          key: ValueKey(media.id),
                          url: media.url,
                          play: play,
                          aspectRatio: aspectRatio,
                          blurHash: media.blurHash,
                          withSound: withSound,
                          onSoundToggled: (enable) {
                            videoPlayer.withSound.value = enable;
                          },
                        );
                      },
                    );
                  },
                );
              },
      );
    }

    return PostLarge(
      key: ValueKey(block.id),
      block: block,
      isOwner: isOwner,
      isLiked: isLiked,
      likePost: () => bloc.add(PostLikeRequested(user.id)),
      likesCount: likesCount,
      createdAt: block.createdAt.timeAgo(context),
      isFollowed: isOwner || (isFollowed ?? false),
      wasFollowed: true,
      follow: () => bloc.add(
        PostAuthorFollowRequested(
          authorId: block.author.id,
          currentUserId: user.id,
        ),
      ),
      enableFollowButton: true,
      commentsCount: commentsCount,
      likesText: l10n.likesCountText,
      commentsText: l10n.seeAllComments,
      postIndex: postIndex,
      withInViewNotifier: withInViewNotifier,
      likesCountBuilder: (name, userId, count) => name == null
          ? null
          : Text.rich(
              t.likedBy(
                name: TextSpan(
                  text: name,
                  style: context.titleMedium
                      ?.copyWith(fontWeight: AppFontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = userId == null
                        ? null
                        : () => context.pushNamed(
                              'user_profile',
                              pathParameters: {'user_id': userId},
                            ),
                ),
                and: TextSpan(text: count < 1 ? '' : l10n.and),
                others: TextSpan(
                  text: l10n.others(count),
                  style: context.titleMedium
                      ?.copyWith(fontWeight: AppFontWeight.bold),
                ),
              ),
              style: context.titleMedium,
            ),
      postAuthorAvatarBuilder: (context, author, onAvatarTap) {
        return UserStoriesAvatar(
          author: author.toUser,
          onAvatarTap: onAvatarTap,
          enableUnactiveBorder: false,
          withAdaptiveBorder: false,
        );
      },
      postOptionsSettings: isOwner
          ? PostOptionsSettings.owner(
              onPostDelete: (_) => bloc.add(const PostDeleteRequested()),
            )
          : const PostOptionsSettings.viewer(),
      onCommentsTap: (showFullSized) => context.showScrollableModal(
        showFullSized: showFullSized,
        pageBuilder: (scrollController, draggableScrollController) =>
            CommentsPage(
          post: block,
          scrollController: scrollController,
          draggableScrollController: draggableScrollController,
        ),
      ),
      onPressed: (action, _) => action?.when(
        navigateToPostAuthor: (action) => context.pushNamed(
          'user_profile',
          pathParameters: {'user_id': action.authorId},
        ),
        navigateToSponsoredPostAuthor: (action) => context.pushNamed(
          'user_profile',
          pathParameters: {'user_id': action.authorId},
          queryParameters: {
            'promo_action': json.encode(action.toJson()),
          },
          extra: true,
        ),
      ),
      onPostShareTap: (postId, author) => context.showScrollableModal(
        pageBuilder: (scrollController, draggableScrollController) => SharePost(
          block: block,
          scrollController: scrollController,
          draggableScrollController: draggableScrollController,
        ),
      ),
      videoPlayerBuilder: !withCustomVideoPlayer
          ? null
          : (_, media, aspectRatio, isInView) {
              final videoPlayer =
                  VideoPlayerProvider.of(context).videoPlayerState;

              return VideoPlayerNotifierWidget(
                type: videoPlayerType,
                builder: (context, shouldPlay, child) {
                  final play = shouldPlay && isInView;
                  return ValueListenableBuilder(
                    valueListenable: videoPlayer.withSound,
                    builder: (context, withSound, child) {
                      return VideoPlay(
                        key: ValueKey(media.id),
                        url: media.url,
                        play: play,
                        aspectRatio: aspectRatio,
                        blurHash: media.blurHash,
                        withSound: withSound,
                        onSoundToggled: (enable) {
                          videoPlayer.withSound.value = enable;
                        },
                      );
                    },
                  );
                },
              );
            },
    );
  }
}
