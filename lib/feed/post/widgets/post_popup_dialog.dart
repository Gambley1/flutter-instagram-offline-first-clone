import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart' hide NumDurationExtension;
import 'package:sprung/sprung.dart';

class PostPopupDialog extends StatelessWidget {
  const PostPopupDialog({
    required this.block,
    required this.popupDialogAnimationController,
    required this.likeIconAnimationController,
    required this.messageVisibility,
    required this.messageText,
    required this.messagePositionLeft,
    required this.likeButtonKey,
    required this.commentOrViewProfileButtonKey,
    required this.sharePostKey,
    required this.optionsKey,
    required this.showComments,
    super.key,
  });

  final PostBlock block;
  final AnimationController popupDialogAnimationController;
  final AnimationController likeIconAnimationController;
  final ValueNotifier<bool> messageVisibility;
  final ValueNotifier<String> messageText;
  final ValueNotifier<double> messagePositionLeft;
  final GlobalKey likeButtonKey;
  final GlobalKey commentOrViewProfileButtonKey;
  final GlobalKey sharePostKey;
  final GlobalKey optionsKey;
  final bool showComments;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedPopupDialog(
        controller: popupDialogAnimationController,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: context.customReversedAdaptiveColor(
              light: AppColors.brightGrey,
              dark: context.theme.splashColor,
            ),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupDialogHeader(block: block),
                PopupDialogBody(
                  block: block,
                  messageVisibility: messageVisibility,
                  messageText: messageText,
                  messagePositionLeft: messagePositionLeft,
                  likeIconAnimationController: likeIconAnimationController,
                ),
                PopupDialogFooter(
                  likeButtonKey: likeButtonKey,
                  commentOrViewProfileButtonKey: commentOrViewProfileButtonKey,
                  showComments: showComments,
                  sharePostKey: sharePostKey,
                  optionsKey: optionsKey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PopupDialogHeader extends StatelessWidget {
  const PopupDialogHeader({required this.block, super.key});

  final PostBlock block;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxxs,
      ),
      horizontalTitleGap: AppSpacing.sm,
      leading: UserProfileAvatar(
        avatarUrl: block.author.avatarUrl,
        isLarge: false,
        enableBorder: false,
        withAdaptiveBorder: false,
      ),
      title: Text(
        block.author.username,
        style: context.bodyLarge,
      ),
    );
  }
}

class PopupDialogBody extends StatelessWidget {
  const PopupDialogBody({
    required this.block,
    required this.messageVisibility,
    required this.messageText,
    required this.messagePositionLeft,
    required this.likeIconAnimationController,
    super.key,
  });

  final PostBlock block;
  final ValueNotifier<bool> messageVisibility;
  final ValueNotifier<String> messageText;
  final ValueNotifier<double> messagePositionLeft;
  final AnimationController likeIconAnimationController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (block.firstMedia is ImageMedia)
          AspectRatio(
            aspectRatio: 1,
            child: ImageAttachmentThumbnail(
              image: Attachment(imageUrl: block.firstMediaUrl),
              fit: BoxFit.cover,
            ),
          )
        else
          VideoPlay(
            url: block.firstMedia!.url,
            blurHash: block.firstMedia!.blurHash,
            withPlayControll: false,
            play: true,
          ),
        AnimatedBuilder(
          animation: Listenable.merge(
            [
              messageVisibility,
              messageText,
              messagePositionLeft,
            ],
          ),
          builder: (context, _) {
            return _PopupMessageDialog(
              visible: messageVisibility.value,
              message: messageText.value,
              widgetPositionLeft: messagePositionLeft.value,
            );
          },
        ),
        LikeAnimatedIcon(controller: likeIconAnimationController),
      ],
    );
  }
}

class PopupDialogFooter extends StatelessWidget {
  const PopupDialogFooter({
    required this.likeButtonKey,
    required this.commentOrViewProfileButtonKey,
    required this.showComments,
    required this.sharePostKey,
    required this.optionsKey,
    super.key,
  });

  final GlobalKey<State<StatefulWidget>> likeButtonKey;
  final GlobalKey<State<StatefulWidget>> commentOrViewProfileButtonKey;
  final bool showComments;
  final GlobalKey<State<StatefulWidget>> sharePostKey;
  final GlobalKey<State<StatefulWidget>> optionsKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            key: likeButtonKey,
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                final isLiked = state.isLiked;

                return Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.red : null,
                  size: 28,
                );
              },
            ),
          ),
          SizedBox(
            key: commentOrViewProfileButtonKey,
            child: showComments
                ? Assets.icons.chatCircle.svg(
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      context.adaptiveColor,
                      BlendMode.srcIn,
                    ),
                  )
                : Assets.icons.user.svg(
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      context.adaptiveColor,
                      BlendMode.srcIn,
                    ),
                  ),
          ),
          SizedBox(
            key: sharePostKey,
            child: const Icon(Icons.near_me_outlined, size: 28),
          ),
          SizedBox(
            key: optionsKey,
            child: const Icon(Icons.more_vert, size: 28),
          ),
        ],
      ),
    );
  }
}

class LikeAnimatedIcon extends StatelessWidget {
  const LikeAnimatedIcon({required this.controller, super.key});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => AnimatedOpacity(
          duration: 50.ms,
          opacity: controller.isAnimating ? 1 : 0,
          child: const Icon(
            Icons.favorite,
            color: AppColors.white,
            size: 100,
          )
              .animate(
                autoPlay: false,
                controller: controller,
              )
              .scaleXY(
                end: 1.3,
                curve: Sprung.custom(damping: 5, stiffness: 85),
                duration: 350.ms,
              )
              .then(delay: 150.ms, curve: Curves.linear)
              .scaleXY(end: 1 / 1.3, duration: 150.ms)
              .fadeOut(duration: 150.ms),
        ),
      ),
    );
  }
}

class _PopupMessageDialog extends StatelessWidget {
  const _PopupMessageDialog({
    required this.message,
    required this.visible,
    required this.widgetPositionLeft,
  });

  final String message;
  final bool visible;
  final double widgetPositionLeft;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Positioned(
        bottom: AppSpacing.lg + AppSpacing.xs,
        left: widgetPositionLeft,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(.7),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm - AppSpacing.xxs,
          ),
          child: Text(
            message,
            style: context.bodyMedium?.apply(color: AppColors.white),
          ),
        )
            .animate(
              onComplete: (_) => HapticFeedback.vibrate(),
            )
            .moveY(
              duration: 250.ms,
              begin: 10,
              end: 0,
              curve: Sprung.custom(damping: 7, stiffness: 65),
            ),
      ),
    );
  }
}

class AnimatedPopupDialog extends StatefulWidget {
  const AnimatedPopupDialog({required this.child, this.controller, super.key});

  final AnimationController? controller;
  final Widget child;

  @override
  State<StatefulWidget> createState() => AnimatedPopupDialogState();
}

class AnimatedPopupDialogState extends State<AnimatedPopupDialog>
    with SafeSetStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sigmaBlurXAnimation;
  late Animation<double> _sigmaBlurYAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = widget.controller!..addListener(_animationListener);
    _opacityAnimation = Tween<double>(begin: 0, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo),
    );
    _sigmaBlurXAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo),
    );
    _sigmaBlurYAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo),
    );
  }

  void _animationListener() => safeSetState(() {});

  @override
  void dispose() {
    _animationController.removeListener(_animationListener);
    if (widget.controller == null) _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: _sigmaBlurXAnimation.value * 13,
        sigmaY: _sigmaBlurYAnimation.value * 10,
      ),
      child: Material(
        color: AppColors.black.withOpacity(_opacityAnimation.value),
        child: Center(
          child: widget.child
              .animate(autoPlay: true, controller: _animationController)
              .scaleXY(
                duration: 450.ms,
                curve: Sprung.custom(damping: 12, stiffness: 60),
              )
              .fadeIn(),
        ),
      ),
    );
  }
}
