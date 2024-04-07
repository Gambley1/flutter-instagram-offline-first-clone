import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comments.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
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
        ..add(const PostIsLikedSubscriptionRequested())
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

    final isOwner = context.select((PostBloc bloc) => bloc.state.isOwner);
    final isLiked = context.select((PostBloc bloc) => bloc.state.isLiked);
    final likesCount = context.select((PostBloc bloc) => bloc.state.likes);
    final isFollowed = context.select((PostBloc bloc) => bloc.state.isFollowed);
    final commentsCount =
        context.select((PostBloc bloc) => bloc.state.commentsCount);

    if (block is PostSponsoredBlock) {
      return PostSponsored(
        key: ValueKey(block.id),
        block: block as PostSponsoredBlock,
        isOwner: isOwner,
        isLiked: isLiked,
        likePost: () => bloc.add(const PostLikeRequested()),
        likesCount: likesCount,
        isFollowed: isOwner || (isFollowed ?? true),
        wasFollowed: true,
        follow: () =>
            bloc.add(PostAuthorFollowRequested(authorId: block.author.id)),
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
        commentsCount: commentsCount,
        postAuthorAvatarBuilder: (context, author, onAvatarTap) {
          return UserStoriesAvatar(
            author: author.toUser,
            onAvatarTap: onAvatarTap,
            enableInactiveBorder: false,
            withAdaptiveBorder: false,
          );
        },
        postOptionsSettings: const PostOptionsSettings.viewer(),
        onUserTap: (userId) => context.pushNamed(
          'user_profile',
          pathParameters: {'user_id': userId},
        ),
        onPressed: (action) => action?.when(
          navigateToPostAuthor: (action) => context.pushNamed(
            'user_profile',
            pathParameters: {'user_id': action.authorId},
          ),
          navigateToSponsoredPostAuthor: (action) => context.pushNamed(
            'user_profile',
            pathParameters: {'user_id': action.authorId},
            extra: UserProfileProps.build(
              isSponsored: true,
              promoBlockAction: action,
              sponsoredPost: block as PostSponsoredBlock,
            ),
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
      likePost: () => bloc.add(const PostLikeRequested()),
      likesCount: likesCount,
      isFollowed: isOwner || (isFollowed ?? true),
      wasFollowed: true,
      follow: () =>
          bloc.add(PostAuthorFollowRequested(authorId: block.author.id)),
      enableFollowButton: true,
      commentsCount: commentsCount,
      postIndex: postIndex,
      withInViewNotifier: withInViewNotifier,
      postAuthorAvatarBuilder: (context, author, onAvatarTap) {
        return UserStoriesAvatar(
          author: author.toUser,
          onAvatarTap: onAvatarTap,
          enableInactiveBorder: false,
          withAdaptiveBorder: false,
        );
      },
      postOptionsSettings: isOwner
          ? PostOptionsSettings.owner(
              onPostEdit: (block) => context.pushNamed(
                'post_edit',
                pathParameters: {'post_id': block.id},
                extra: block,
              ),
              onPostDelete: (_) {
                bloc.add(const PostDeleteRequested());
                context.read<FeedBloc>().add(
                      FeedUpdateRequested(
                        post: block.toPost,
                        isDelete: true,
                      ),
                    );
              },
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
      onUserTap: (userId) => context.pushNamed(
        'user_profile',
        pathParameters: {'user_id': userId},
      ),
      onPressed: (action) => action?.when(
        navigateToPostAuthor: (action) => context.pushNamed(
          'user_profile',
          pathParameters: {'user_id': action.authorId},
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
