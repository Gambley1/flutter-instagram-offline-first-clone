import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comments.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/video/video.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reel/reel.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
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

  final PostReelBlock block;
  final bool withSound;
  final bool play;

  @override
  Widget build(BuildContext context) {
    return PostView(
      key: ValueKey(block.id),
      block: block,
      videoPlayerType: VideoPlayerType.reels,
      builder: (context) => Reel(
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

  final PostReelBlock block;
  final bool withSound;
  final bool play;

  @override
  State<Reel> createState() => _ReelState();
}

class _ReelState extends State<Reel> {
  late VideoPlayerController _videoController;
  late ValueNotifier<bool> _isPaused;
  late ValueNotifier<bool> _isLiked;

  late StreamSubscription<PostState> _postStateSubscription;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.block.reel.url),
    );
    _isPaused = ValueNotifier(false)..addListener(_isPausedListener);
    _isLiked = ValueNotifier(false);

    _postStateSubscription = _isLikedListener();
  }

  void _isPausedListener() {
    if (_isPaused.value) {
      _videoController.pause();
    } else {
      Future<void>.delayed(300.ms, () => _videoController.play());
    }
  }

  StreamSubscription<PostState> _isLikedListener() =>
      context.read<PostBloc>().stream.listen((state) {
        _isLiked.value = state.isLiked;
      });

  @override
  void dispose() {
    _videoController
        .pause()
        .then((_) => Future<void>.delayed(2.seconds, _videoController.dispose));
    _isPaused
      ..removeListener(_isPausedListener)
      ..dispose();
    _isLiked.dispose();
    _postStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final block = widget.block;

    return ValueListenableBuilder<bool>(
      valueListenable: _isLiked,
      child: GestureDetector(
        onLongPressStart: (_) => _isPaused.value = true,
        onLongPressEnd: (_) => _isPaused.value = false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InlineVideo(
              videoSettings: VideoSettings.build(
                videoUrl: block.reel.url,
                shouldPlay: widget.play,
                blurHash: block.reel.blurHash,
                withSound: widget.withSound || true,
                aspectRatio: 9 / 15,
                withSoundButton: false,
                withPlayerController: false,
                videoPlayerController: _videoController,
                loadingBuilder: (context) => const ReelShimmerLoading(),
                stackedWidget: ValueListenableBuilder<bool>(
                  valueListenable: _isPaused,
                  child: Stack(
                    children: [
                      VerticalButtons(block),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.md,
                          left: AppSpacing.lg,
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints.tightFor(
                              width: context.screenWidth * .8,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReelAuthorListTile(block: block),
                                if (block.caption.isNotEmpty) ...[
                                  const Gap.v(AppSpacing.md),
                                  ReelCaption(caption: block.caption),
                                ],
                                const Gap.v(AppSpacing.sm),
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
                  builder: (context, isPaused, child) {
                    return AnimatedOpacity(
                      opacity: isPaused ? 0 : 1,
                      duration: 150.ms,
                      child: child,
                    );
                  },
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isPaused,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SmoothVideoProgressIndicator(
                  controller: _videoController,
                ),
              ),
              builder: (context, isPaused, child) {
                return AnimatedOpacity(
                  opacity: isPaused ? 0 : 1,
                  duration: 150.ms,
                  child: child,
                );
              },
            ),
          ],
        ),
      ),
      builder: (context, isLiked, child) {
        return PoppingIconAnimationOverlay(
          onTap: () => context.read<PostBloc>().add(const PostLikeRequested()),
          isLiked: isLiked,
          child: child!,
        );
      },
    );
  }
}

class ReelShimmerLoading extends StatelessWidget {
  const ReelShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.grey,
          highlightColor: const Color(0xFFAFAFAF),
          child: Container(
            width: double.infinity,
            height: double.maxFinite,
            color: AppColors.emphasizeGrey,
          ),
        ),
        Shimmer.fromColors(
          baseColor: AppColors.grey,
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
                  backgroundColor: AppColors.dark,
                ),
                Container(
                  height: 15,
                  width: 150,
                  color: AppColors.dark,
                ),
                Container(
                  height: 15,
                  width: 200,
                  color: AppColors.dark,
                ),
              ].spacerBetween(height: AppSpacing.xs),
            ),
          ),
        ),
      ],
    );
  }
}

class VerticalButtons extends StatelessWidget {
  const VerticalButtons(this.block, {super.key});

  final PostReelBlock block;

  @override
  Widget build(BuildContext context) {
    final isLiked = context.select((PostBloc bloc) => bloc.state.isLiked);
    final likes = context.select((PostBloc bloc) => bloc.state.likes);
    final commentsCount =
        context.select((PostBloc bloc) => bloc.state.commentsCount);
    final isOwner = context.select((PostBloc bloc) => bloc.state.isOwner);

    Future<void> onCommentsTap(PostReelBlock block) =>
        context.showScrollableModal(
          pageBuilder: (scrollController, draggableScrollController) =>
              CommentsPage(
            post: block,
            scrollController: scrollController,
            draggableScrollController: draggableScrollController,
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
              iconColor: isLiked ? AppColors.red : null,
              onButtonTap: () =>
                  context.read<PostBloc>().add(const PostLikeRequested()),
              size: AppSize.iconSize,
              statisticCount: likes,
            ),
            VerticalGroup(
              onButtonTap: () => onCommentsTap.call(block),
              statisticCount: commentsCount,
              child: Assets.icons.chatCircle.svg(
                height: AppSize.iconSize,
                width: AppSize.iconSize,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            VerticalGroup(
              icon: Icons.near_me_outlined,
              onButtonTap: () => context.showScrollableModal(
                pageBuilder: (scrollController, draggableScrollController) =>
                    SharePost(
                  block: block,
                  scrollController: scrollController,
                  draggableScrollController: draggableScrollController,
                ),
              ),
              size: AppSize.iconSize,
              withStatistic: false,
            ),
            VerticalGroup(
              icon: Icons.more_vert_sharp,
              onButtonTap: !isOwner
                  ? null
                  : () => context.showListOptionsModal(
                        options: [
                          ModalOption(
                            name: context.l10n.deleteText,
                            actionTitle: context.l10n.deleteReelText,
                            actionContent:
                                context.l10n.reelDeleteConfirmationText,
                            actionYesText: context.l10n.deleteText,
                            actionNoText: context.l10n.cancelText,
                            icon: Assets.icons.trash.svg(
                              colorFilter: const ColorFilter.mode(
                                AppColors.red,
                                BlendMode.srcIn,
                              ),
                            ),
                            distractive: true,
                            onTap: () {
                              context
                                  .read<PostBloc>()
                                  .add(const PostDeleteRequested());
                              context.read<FeedBloc>().add(
                                    FeedUpdateRequested(
                                      update: FeedPageUpdate(
                                        newPost: block.toPost,
                                        type: PageUpdateType.delete,
                                      ),
                                    ),
                                  );
                            },
                          ),
                        ],
                      ).then((option) {
                        if (option == null) return;
                        void onTap() => option.onTap(context);
                        onTap.call();
                      }),
              withStatistic: false,
            ),
            Tappable(
              onTap: () {},
              animationEffect: TappableAnimationEffect.scale,
              scaleStrength: ScaleStrength.xxs,
              child: ImageAttachmentThumbnail(
                image: Attachment(
                  imageUrl: block.author.avatarUrl,
                  originalHeight: AppSize.iconSize.toInt(),
                  originalWidth: AppSize.iconSize.toInt(),
                ),
                borderRadius: 4,
                border: Border.all(color: AppColors.white),
                filterQuality: FilterQuality.high,
              ),
            ),
          ].spacerBetween(height: AppSpacing.lg),
        ),
      ),
    );
  }
}

class ReelAuthorListTile extends StatelessWidget {
  const ReelAuthorListTile({required this.block, super.key});

  final PostReelBlock block;

  @override
  Widget build(BuildContext context) {
    final author = block.author;

    final isFollowed = context.select((PostBloc bloc) => bloc.state.isFollowed);
    final isOwner = context.select((PostBloc bloc) => bloc.state.isOwner);

    final l10n = context.l10n;

    return Row(
      children: <Widget>[
        UserStoriesAvatar(
          resizeHeight: 108,
          author: author.toUser,
          withAdaptiveBorder: false,
          enableInactiveBorder: false,
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
            style: context.bodyLarge?.copyWith(
              fontWeight: AppFontWeight.bold,
              color: AppColors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isOwner)
          Flexible(
            flex: 3,
            child: Tappable(
              onTap: () => context
                  .read<PostBloc>()
                  .add(PostAuthorFollowRequested(authorId: author.id)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: AppColors.white),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xxs,
                  ),
                  child: Align(
                    child: Text(
                      isFollowed ?? false
                          ? l10n.followingUser
                          : l10n.followUser,
                      style: context.bodyLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: AppFontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ].spacerBetween(width: AppSpacing.sm),
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
          child: Tappable(
            onTap: () {},
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.customReversedAdaptiveColor(
                  light: AppColors.lightDark,
                  dark: AppColors.dark,
                ),
                border: Border.all(color: AppColors.borderOutline),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: AppSize.iconSizeSmall,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const Gap.h(AppSpacing.sm),
                  Flexible(
                    flex: 6,
                    child: RunningText(
                      text: '$participant • ${context.l10n.originalAudioText}',
                      velocity: 40,
                      style: context.bodyMedium?.apply(
                        color: AppColors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Tappable(
          onTap: () {},
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.customReversedAdaptiveColor(
                light: AppColors.lightDark,
                dark: AppColors.dark,
              ),
              border: Border.all(color: AppColors.borderOutline),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Align(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.person,
                      size: AppSize.iconSizeSmall,
                      color: AppColors.white,
                    ),
                    Text(
                      participant,
                      style: context.bodyMedium?.apply(color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ].spacerBetween(width: AppSpacing.xs),
                ),
              ),
            ),
          ),
        ),
      ].spacerBetween(width: AppSpacing.sm),
    );
  }
}
