import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/comments/view/comments_page.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart' hide NumDurationExtension;
import 'package:user_repository/user_repository.dart';

class PositionDimension extends Equatable {
  const PositionDimension({
    required this.positionTop,
    required this.positionBottom,
    required this.positionLeft,
    required this.positionRight,
    required this.positionCenter,
  });

  final double positionTop;
  final double positionBottom;
  final double positionLeft;
  final double positionRight;
  final double positionCenter;

  @override
  List<Object> get props => [
        positionTop,
        positionBottom,
        positionLeft,
        positionRight,
        positionCenter,
      ];
}

class PostPopup extends StatelessWidget {
  const PostPopup({
    required this.block,
    required this.index,
    required this.builder,
    this.showComments = true,
    super.key,
  });

  final PostBlock block;
  final int index;
  final WidgetBuilder builder;
  final bool showComments;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(
        postId: block.id,
        postsRepository: context.read<PostsRepository>(),
        userRepository: context.read<UserRepository>(),
      )..add(const PostIsLikedSubscriptionRequested()),
      child: PopupModal(
        block: block,
        index: index,
        builder: builder,
        showComments: showComments,
      ),
    );
  }
}

class PopupModal extends StatefulWidget {
  const PopupModal({
    required this.block,
    required this.index,
    required this.builder,
    required this.showComments,
    super.key,
  });

  final PostBlock block;
  final int index;
  final WidgetBuilder builder;
  final bool showComments;

  @override
  State<PopupModal> createState() => _PostPopupState();
}

class _PostPopupState extends State<PopupModal>
    with TickerProviderStateMixin, SafeSetStateMixin {
  late AnimationController _likeAnimationController;
  late AnimationController _popupDialogAnimationController;

  final _likeButtonKey = GlobalKey();
  final _commentOrViewProfileButtonKey = GlobalKey();
  final _sharePostKey = GlobalKey();
  final _optionsKey = GlobalKey();

  OverlayEntry? _popupDialog;
  OverlayEntry? _popupEmptyDialog;

  final _messageVisibility = ValueNotifier(false);
  final _likeVisibility = ValueNotifier(false);
  final _commentOrViewProfileVisibility = ValueNotifier(false);
  final _sharePostVisibility = ValueNotifier(false);
  final _optionsVisibility = ValueNotifier(false);

  final _messagePositionLeft = ValueNotifier<double>(0);
  final _messageText = ValueNotifier('');

  final _isLiked = ValueNotifier(false);
  StreamSubscription<PostState>? _isLikedSubscription;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(vsync: this);
    _popupDialogAnimationController = AnimationController(
      vsync: this,
      duration: 150.ms,
      reverseDuration: 400.ms,
    )..addStatusListener(_popupDialogStatusListener);

    _isLikedSubscription = context.read<PostBloc>().stream.listen((state) {
      _isLiked.value = state.isLiked;
    });
  }

  Future<void> _popupDialogStatusListener(AnimationStatus status) async {
    if (status == AnimationStatus.dismissed) {
      _popupDialog?.remove();
      _popupEmptyDialog?.remove();
      if (_commentOrViewProfileVisibility.value) {
        await showCommentsOrViewProfile();
      }
      if (_sharePostVisibility.value) await sharePost();
    }
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _popupDialogAnimationController
      ..removeStatusListener(_popupDialogStatusListener)
      ..dispose();
    _messageVisibility.dispose();
    _likeVisibility.dispose();
    _commentOrViewProfileVisibility.dispose();
    _sharePostVisibility.dispose();
    _optionsVisibility.dispose();
    _isLiked.dispose();
    _isLikedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppBloc>().state.user;

    return ValueListenableBuilder<bool>(
      valueListenable: _isLiked,
      child: RepaintBoundary(child: widget.builder.call(context)),
      builder: (context, isLiked, child) {
        return Tappable(
          onTap: () => context.pushNamed(
            'user_posts',
            queryParameters: {
              'user_id': widget.block.author.id,
              'index': widget.index.toString(),
            },
          ),
          onLongPressMoveUpdate: (details) => onLongPressMoveUpdate(
            details,
            isLiked: isLiked,
            context: context,
          ),
          onLongPress: () => onLongPress(context.read<PostBloc>()),
          onLongPressEnd: (details) => onLongPressEnd(
            details,
            userId: user.id,
            isLiked: isLiked,
            context: context,
          ),
          child: child!,
        );
      },
    );
  }

  void onLongPressMoveUpdate(
    LongPressMoveUpdateDetails details, {
    required BuildContext context,
    required bool isLiked,
  }) {
    final l10n = context.l10n;

    final likePosition = _getOffset(_likeButtonKey);
    final commentPosition = _getOffset(_commentOrViewProfileButtonKey);
    final sharePosition = _getOffset(_sharePostKey);
    final optionsPosition = _getOffset(_optionsKey);

    bool isInside(PositionDimension dimension) =>
        details.globalPosition.dy > dimension.positionTop &&
        details.globalPosition.dy < dimension.positionBottom &&
        details.globalPosition.dx > dimension.positionLeft &&
        details.globalPosition.dx < dimension.positionRight;

    if (isInside(likePosition)) {
      _messageText.value = isLiked ? l10n.unlikeText : l10n.likeText;
      _messagePositionLeft.value = likePosition.positionLeft -
          likePosition.positionCenter -
          (isLiked ? 15 : 7);
      _likeVisibility.value = true;
      _messageVisibility.value = true;
    } else if (isInside(commentPosition)) {
      _messageText.value =
          widget.showComments ? l10n.commentText : l10n.viewProfileText;
      _messagePositionLeft.value =
          commentPosition.positionLeft - commentPosition.positionCenter - 30;
      _commentOrViewProfileVisibility.value = true;
      _messageVisibility.value = true;
    } else if (isInside(sharePosition)) {
      _messageText.value = l10n.sharePostText;
      _messagePositionLeft.value =
          sharePosition.positionLeft - sharePosition.positionCenter - 12;
      _sharePostVisibility.value = true;
      _messageVisibility.value = true;
    } else if (isInside(optionsPosition)) {
      _messageText.value = l10n.optionsText;
      _messagePositionLeft.value =
          optionsPosition.positionLeft - optionsPosition.positionCenter - 15;
      _optionsVisibility.value = true;
      _messageVisibility.value = true;
    } else {
      _messageText.value = '';
      _messagePositionLeft.value = 0;
      _likeVisibility.value = false;
      _commentOrViewProfileVisibility.value = false;
      _sharePostVisibility.value = false;
      _optionsVisibility.value = false;
      _messageVisibility.value = false;
    }

    _popupEmptyDialog = _createPopupEmptyDialog();
    Overlay.of(context).insert(_popupEmptyDialog!);
  }

  void onLongPress(PostBloc bloc) {
    _popupDialog = _createPopupDialog(bloc);
    Overlay.of(context).insert(_popupDialog!);
    _popupEmptyDialog = _createPopupEmptyDialog();
    Overlay.of(context).insert(_popupEmptyDialog!);
  }

  Future<void> onLongPressEnd(
    LongPressEndDetails details, {
    required String userId,
    required bool isLiked,
    required BuildContext context,
  }) async {
    if (_likeVisibility.value) {
      context.read<PostBloc>().add(PostLikeRequested(userId));
      if (!isLiked) {
        _animateLike();
        await Future<void>.delayed(550.ms);
      }
    }

    _messageVisibility.value = false;
    _animateDialogBack();
  }

  void _animateLike() => _likeAnimationController.loop(count: 1);

  void _animateDialogBack() => _popupDialogAnimationController.reverse();

  Future<void> showCommentsOrViewProfile() async {
    if (widget.showComments) {
      await context.showScrollableModal(
        showFullSized: true,
        pageBuilder: (scrollController, draggableScrollController) =>
            CommentsPage(
          post: widget.block,
          scrollController: scrollController,
          draggableScrollController: draggableScrollController,
        ),
      );
    } else {
      await context.pushNamed(
        'user_profile',
        pathParameters: {'user_id': widget.block.author.id},
      );
    }
  }

  Future<void> sharePost() => context.showScrollableModal(
        pageBuilder: (scrollController, draggableScrollController) => SharePost(
          block: widget.block,
          scrollController: scrollController,
          draggableScrollController: draggableScrollController,
        ),
      );

  PositionDimension _getOffset(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final position = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final widgetSize = key.currentContext?.size ?? Size.zero;
    final widgetWidth = widgetSize.width;
    final positionDimension = PositionDimension(
      positionTop: position.dy,
      positionBottom: position.dy + 50,
      positionLeft: position.dx,
      positionRight: position.dx + 50,
      positionCenter: widgetWidth / 2,
    );

    return positionDimension;
  }

  OverlayEntry _createPopupDialog(PostBloc bloc) => OverlayEntry(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: PostPopupDialog(
            block: widget.block,
            popupDialogAnimationController: _popupDialogAnimationController,
            likeIconAnimationController: _likeAnimationController,
            messageVisibility: _messageVisibility,
            messageText: _messageText,
            messagePositionLeft: _messagePositionLeft,
            likeButtonKey: _likeButtonKey,
            commentOrViewProfileButtonKey: _commentOrViewProfileButtonKey,
            sharePostKey: _sharePostKey,
            optionsKey: _optionsKey,
            showComments: widget.showComments,
          ),
        ),
      );

  OverlayEntry _createPopupEmptyDialog() => OverlayEntry(
        builder: (context) => const SizedBox(),
      );
}
