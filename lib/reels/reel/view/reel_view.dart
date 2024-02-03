// ignore_for_file: deprecated_member_use

import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comments.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reel/bloc/reel_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reel/widgets/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reels.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_repository/user_repository.dart';

class ReelView extends StatelessWidget {
  const ReelView({
    required this.block,
    required this.withSound,
    required this.play,
    super.key,
  });

  final PostBlock block;
  final bool withSound;
  final bool play;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return BlocProvider(
      create: (context) => ReelBloc(
        reelId: block.id,
        userRepository: context.read<UserRepository>(),
        postsRepository: context.read<PostsRepository>(),
      )
        ..add(const ReelLikesCountSubscriptionRequested())
        ..add(const ReelCommentsCountSubscriptionRequested())
        ..add(ReelIsLikedSubscriptionRequested(user.id))
        ..add(
          ReelAuthoFollowingStatusSubscriptionRequested(
            ownerId: block.author.id,
            currentUserId: user.id,
          ),
        ),
      child: Reel(
        block: block,
        withSound: withSound,
        play: play,
      ),
    );
  }
}

class Reel extends StatefulWidget {
  const Reel({
    required this.block,
    required this.play,
    required this.withSound,
    super.key,
  });

  final PostBlock block;
  final bool withSound;
  final bool play;

  @override
  State<Reel> createState() => _ReelState();
}

class _ReelState extends State<Reel> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = widget.block is! PostReelBlock
        ? null
        : VideoPlayerController.networkUrl(
            Uri.parse((widget.block as PostReelBlock).reel!.url),
          );
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select((ReelsBloc bloc) => bloc.state.status);
    if (widget.block is! PostReelBlock) {
      return SizedBox.expand(
        child: Center(
          child: Text(
            'An error occured!',
            style: context.bodyMedium?.copyWith(
              fontWeight: AppFontWeight.bold,
            ),
          ),
        ),
      );
    }
    final block = widget.block as PostReelBlock;
    if (block.reel == null && status != ReelsStatus.loading) {
      return SizedBox.expand(
        child: Center(
          child: Text(
            'No media found!',
            style: context.bodyMedium?.copyWith(
              fontWeight: AppFontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlay(
          url: block.reel!.url,
          play: widget.play,
          blurHash: block.reel!.blurHash,
          withSound: widget.withSound || true,
          aspectRatio: 9 / 15,
          withSoundButton: false,
          withPlayControll: false,
          controller: _videoController,
          loadingBuilder: (context) => Stack(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[500]!,
                highlightColor: const Color(0xFFAFAFAF),
                child: Container(
                  width: double.infinity,
                  height: double.maxFinite,
                  color: const Color(0xff696969),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[600]!,
                highlightColor: const Color(0xFFAFAFAF),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: 25,
                    bottom: 20,
                    start: 15,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xff282828),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 15,
                        width: 150,
                        color: const Color(0xff282828),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 15,
                        width: 200,
                        color: const Color(0xff282828),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          stackedWidgets: [
            VerticalButtons(block),
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.md,
                left: AppSpacing.lg,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints.tightFor(width: context.screenWidth * .8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReelAuthorListTile(block: block),
                      if (block.caption.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        ReelCaption(caption: block.caption),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 32,
                        child: ReelParticipants(
                          participant: block.author.username,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_videoController != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: SmoothVideoProgressIndicator(controller: _videoController!),
          ),
      ],
    );
  }
}

class VerticalButtons extends StatelessWidget {
  const VerticalButtons(this.block, {super.key});

  final PostBlock block;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isLiked = context.select((ReelBloc bloc) => bloc.state.isLiked);
    final likes = context.select((ReelBloc bloc) => bloc.state.likes);
    final commentsCount =
        context.select((ReelBloc bloc) => bloc.state.commentsCount);
    final isOwner = context.select((ReelBloc bloc) => bloc.state.isOwner);

    Future<void> onCommentsTap(PostBlock block) => context.showCommentsModal(
          pageBuilder: (scrollController, draggableScrollController) =>
              CommentsPage(
            post: block,
            scrollController: scrollController,
            scrollableSheetController: draggableScrollController,
          ),
        );

    return Padding(
      padding:
          const EdgeInsets.only(right: AppSpacing.md, bottom: AppSpacing.md),
      child: Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            VerticalGroup(
              icon: isLiked ? Icons.favorite : Icons.favorite_outline,
              iconColor: isLiked ? Colors.red : null,
              onButtonTap: () =>
                  context.read<ReelBloc>().add(ReelLikeRequested(user.id)),
              size: AppSize.iconSize,
              statisticCount: likes,
            ),
            VerticalGroup(
              onButtonTap: () => onCommentsTap.call(block),
              statisticCount: commentsCount,
              child: Assets.icons.chatCircle.svg(
                height: AppSize.iconSize,
                width: AppSize.iconSize,
                color: context.adaptiveColor,
              ),
            ),
            VerticalGroup(
              icon: Icons.near_me_outlined,
              onButtonTap: () {},
              size: AppSize.iconSize,
              withStatistic: false,
            ),
            VerticalGroup(
              icon: Icons.more_vert_sharp,
              onButtonTap: !isOwner
                  ? () {}
                  : () async {
                      final option = await context.showListOptionsModal(
                        options: [
                          ModalOption(
                            name: 'Delete reel',
                            child: Assets.icons.trash.svg(color: Colors.red),
                            distractive: true,
                            onTap: () => context
                                .read<ReelBloc>()
                                .add(ReelDeleteRequested(block.id)),
                          ),
                        ],
                      );
                      if (option == null) return;
                      await Future.microtask(
                        () => option.distractiveCallback.call(context),
                      );
                    },
              withStatistic: false,
            ),
            Tappable(
              onTap: () {},
              animationEffect: TappableAnimationEffect.scale,
              scaleStrength: ScaleStrength.xxs,
              child: Container(
                height: AppSize.iconSize,
                width: AppSize.iconSize,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Colors.white),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      block.author.avatarUrl,
                      cacheKey: block.author.avatarUrl,
                      maxHeight: AppSize.iconSize.toInt(),
                      maxWidth: AppSize.iconSize.toInt(),
                    ),
                  ),
                ),
              ),
            ),
          ].insertBetween(const SizedBox(height: AppSpacing.lg)),
        ),
      ),
    );
  }
}

class ReelAuthorListTile extends StatelessWidget {
  const ReelAuthorListTile({required this.block, super.key});

  final PostBlock block;

  @override
  Widget build(BuildContext context) {
    final author = block.author;

    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isFollowed = context.select((ReelBloc bloc) => bloc.state.isFollowed);
    final isOwner = context.select((ReelBloc bloc) => bloc.state.isOwner);
    return Row(
      children: <Widget>[
        UserStoriesAvatar(
          author: author.toUser,
          withAdaptiveBorder: false,
          radius: 18,
          enableUnactiveBorder: false,
        ),
        Flexible(
          flex: 4,
          child: Text.rich(
            TextSpan(
              text: author.username,
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.pushNamed(
                      'user_profile',
                      pathParameters: {'user_id': author.id},
                    ),
            ),
            style: context.bodyLarge?.copyWith(fontWeight: AppFontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isOwner)
          Flexible(
            flex: 3,
            child: Tappable(
              onTap: () => context.read<ReelBloc>().add(
                    ReelAuthorSubscribeRequested(
                      authorId: author.id,
                      currentUserId: user.id,
                    ),
                  ),
              child: FittedBox(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Align(
                      child: Text(
                        isFollowed ?? false ? 'Following' : 'Follow',
                        style: context.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: AppFontWeight.bold,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ].insertBetween(const SizedBox(width: AppSpacing.sm)),
    );
  }
}

class ReelCaption extends StatelessWidget {
  const ReelCaption({required this.caption, super.key});

  final String caption;

  @override
  Widget build(BuildContext context) {
    return Text(
      caption,
      style: context.titleSmall?.copyWith(),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class ReelParticipants extends StatelessWidget {
  const ReelParticipants({required this.participant, super.key});

  final String participant;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 4,
          child: Tappable(
            onTap: () {},
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color.fromARGB(165, 58, 58, 58),
                border: Border.all(
                  color: const Color.fromARGB(
                    45,
                    250,
                    250,
                    250,
                  ),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: AppSize.iconSizeSmall,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    flex: 6,
                    child: RunningText(
                      text: '$participant:Original audio'
                          .insertBetween('•', splitBy: ':'),
                      velocity: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: FittedBox(
            child: Tappable(
              onTap: () {},
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(165, 58, 58, 58),
                  border: Border.all(
                    color: const Color.fromARGB(
                      45,
                      250,
                      250,
                      250,
                    ),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Align(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.person, size: AppSize.iconSizeSmall),
                        Text(participant),
                      ].insertBetween(
                        const SizedBox(
                          width: AppSpacing.xs,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ].insertBetween(const SizedBox(width: AppSpacing.sm)),
    );
  }
}
