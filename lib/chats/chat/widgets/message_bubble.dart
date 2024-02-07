// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' hide Selectable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/attachments/widgets/thumnail/thumbnail.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/chat.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef MessageTapCallback<T> = Future<T?> Function(
  TapUpDetails details,
  String messageId, {
  required bool isMine,
  required bool hasSharedPost,
});

typedef MessageBuilder = Widget Function(
  BuildContext,
  Message message,
  List<Message>,
  MessageBubble defaultMessageWidget,
);

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    required this.message,
    required this.onMessageTap,
    this.onEditTap,
    this.onReplyTap,
    this.onDeleteTap,
    this.borderRadius,
    super.key,
  });

  final ValueSetter<Message>? onReplyTap;
  final ValueSetter<Message>? onEditTap;
  final ValueSetter<Message>? onDeleteTap;
  final Message message;
  final BorderRadiusGeometry Function(bool)? borderRadius;
  final MessageTapCallback<MessageAction> onMessageTap;

  MessageBubble copyWith({
    ValueSetter<Message>? onReplyTap,
    ValueSetter<Message>? onEditTap,
    ValueSetter<Message>? onDeleteTap,
    Message? message,
    BorderRadiusGeometry Function(bool)? borderRadius,
    MessageTapCallback<MessageAction>? onMessageTap,
  }) =>
      MessageBubble(
        message: message ?? this.message,
        onMessageTap: onMessageTap ?? this.onMessageTap,
        onReplyTap: onReplyTap ?? this.onReplyTap,
        onEditTap: onEditTap ?? this.onEditTap,
        onDeleteTap: onDeleteTap ?? this.onDeleteTap,
        borderRadius: borderRadius ?? this.borderRadius,
      );

  bool get hasNonUrlAttachments =>
      message.attachments.any((a) => a.type != AttachmentType.urlPreview.value);

  bool get hasUrlAttachments =>
      message.attachments.any((a) => a.type == AttachmentType.urlPreview.value);

  bool get hasAttachments => hasUrlAttachments || hasNonUrlAttachments;

  bool get hasRepliedComment => message.repliedMessage != null;

  bool get displayBottomStatuses => hasAttachments || hasRepliedComment;

  bool get isEdited =>
      message.createdAt.isAfter(message.updatedAt) &&
      !message.createdAt.isAtSameMomentAs(message.updatedAt);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = message.sender?.id == user.id;
    final messageAlignment = !isMine ? Alignment.topLeft : Alignment.topRight;

    return VisibilityDetector(
      key: ValueKey(message.id),
      onVisibilityChanged: (info) {
        if (info.visibleBounds.isEmpty) return;
        if (message.isRead) return;
        if (message.sender?.id == user.id) return;
        context.read<ChatBloc>().add(ChatMessageSeen(message.id));
      },
      child: Tappable(
        animationEffect: TappableAnimationEffect.none,
        onTapUp: (details) async {
          late final onDeleteTap = context.confirmAction(
            fn: () => widget.onDeleteTap?.call(message),
            noText: 'Cancel',
            title: 'Delete this message?',
            yesText: 'Delete',
          );
          final option = await widget.onMessageTap.call(
            details,
            message.id,
            isMine: isMine,
            hasSharedPost: message.sharedPost != null,
          );
          if (option == null) return;
          void action() => switch (option) {
                MessageAction.delete => onDeleteTap,
                MessageAction.edit => widget.onEditTap?.call(message),
                MessageAction.reply => widget.onReplyTap?.call(message),
              };
          action();
        },
        child: FractionallySizedBox(
          alignment: messageAlignment,
          widthFactor: 0.9,
          child: Align(
            alignment: messageAlignment,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ClipRRect(
                borderRadius: widget.borderRadius?.call(isMine) ??
                    const BorderRadius.all(Radius.circular(22)),
                child: RepaintBoundary(
                  child: MessageBubbleContent(
                    isMine: isMine,
                    message: message,
                    hasRepliedComment: widget.hasRepliedComment,
                    displayBottomStatuses: widget.displayBottomStatuses,
                    hasAttachments: widget.hasAttachments,
                    isEdited: widget.isEdited,
                    onReplyTap: widget.onReplyTap,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MessageBubbleContent extends StatelessWidget {
  const MessageBubbleContent({
    required this.isMine,
    required this.message,
    required this.hasRepliedComment,
    required this.displayBottomStatuses,
    required this.hasAttachments,
    required this.isEdited,
    super.key,
    this.onReplyTap,
  });

  final bool isMine;
  final bool hasRepliedComment;
  final bool displayBottomStatuses;
  final bool hasAttachments;
  final bool isEdited;
  final ValueSetter<Message>? onReplyTap;
  final Message message;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = message.sender?.id == user.id;

    late final sharedPost = message.sharedPost;

    return BubbleBackground(
      colors: [
        if (!isMine) ...[
          context.customReversedAdaptiveColor(
            light: const ui.Color.fromARGB(255, 105, 111, 123),
            dark: const ui.Color(0xff1c1e22),
          ),
        ] else ...const [
          ui.Color.fromARGB(255, 226, 128, 53),
          ui.Color.fromARGB(255, 228, 96, 182),
          ui.Color.fromARGB(255, 107, 73, 195),
          ui.Color.fromARGB(255, 78, 173, 195),
        ],
      ],
      child: message.sharedPostId == null && message.message.trim().isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxlg,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Post unavailable',
                    style: context.bodyLarge?.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'This post is unavailable.',
                    style: context.bodyLarge?.apply(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : sharedPost != null
              ? sharedPost.isReel
                  ? Stack(
                      children: [
                        Tappable(
                          animationEffect: TappableAnimationEffect.none,
                          onTap: () => context.pushNamed(
                            'post_details',
                            pathParameters: {'id': sharedPost.id},
                          ),
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: ImageAttachmentThumbnail(
                                  image: Attachment(
                                    imageUrl: sharedPost.firstMediaUrl,
                                  ),
                                  // fit: BoxFit.fitHeight,
                                ),
                              ),
                              Positioned(
                                top: AppSpacing.sm,
                                right: AppSpacing.sm,
                                child: Builder(
                                  builder: (_) {
                                    if (sharedPost.media.length > 1) {
                                      return const Icon(
                                        Icons.layers,
                                        size: AppSize.iconSizeBig,
                                        shadows: [
                                          Shadow(blurRadius: 2),
                                        ],
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              Positioned(
                                top: AppSpacing.sm,
                                left: AppSpacing.sm,
                                right: AppSpacing.sm,
                                child: ListTile(
                                  horizontalTitleGap: AppSpacing.sm,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  leading: UserProfileAvatar(
                                    avatarUrl: sharedPost.author.avatarUrl,
                                    radius: 16,
                                    isLarge: false,
                                    withAdaptiveBorder: false,
                                  ),
                                  title: Text(
                                    sharedPost.author.username,
                                    style: context.bodyLarge?.copyWith(
                                      fontWeight: AppFontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  trailing: Container(
                                    decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 15,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Assets.icons.instagramReel.svg(
                                      height: 36,
                                      width: 36,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          right: 12,
                          bottom: 4,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: MessageStatuses(
                              isEdited: isEdited,
                              message: message,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Tappable(
                          animationEffect: TappableAnimationEffect.none,
                          onTap: () => context.pushNamed(
                            'post_details',
                            pathParameters: {'id': sharedPost.id},
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                horizontalTitleGap: 0,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                leading: UserProfileAvatar(
                                  avatarUrl: sharedPost.author.avatarUrl,
                                  isLarge: false,
                                ),
                                title: Text(
                                  sharedPost.author.username,
                                  style: context.bodyLarge?.copyWith(
                                    fontWeight: AppFontWeight.bold,
                                  ),
                                ),
                              ),
                              Stack(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: ImageAttachmentThumbnail(
                                      image: Attachment(
                                        imageUrl: sharedPost.firstMediaUrl,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Builder(
                                      builder: (_) {
                                        if (sharedPost.isReel) {
                                          return Container(
                                            decoration: const BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 15,
                                                  offset: Offset(2, 2),
                                                ),
                                              ],
                                            ),
                                            child:
                                                Assets.icons.instagramReel.svg(
                                              height: 36,
                                              width: 36,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                Colors.white,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          );
                                        }
                                        if (sharedPost.media.length > 1) {
                                          return const Icon(
                                            Icons.layers,
                                            size: AppSize.iconSizeBig,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 2,
                                              ),
                                            ],
                                          );
                                        }
                                        if (sharedPost.hasBothMediaTypes) {
                                          return const SizedBox.shrink();
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (sharedPost.caption.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  child: Text.rich(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: sharedPost.author.username,
                                          style: context.bodyLarge?.copyWith(
                                            fontWeight: AppFontWeight.bold,
                                          ),
                                        ),
                                        const WidgetSpan(
                                          child: SizedBox(width: AppSpacing.xs),
                                        ),
                                        TextSpan(
                                          text: sharedPost.caption,
                                          style: context.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          right: 12,
                          bottom: 4,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: MessageStatuses(
                              isEdited: isEdited,
                              message: message,
                            ),
                          ),
                        ),
                      ],
                    )
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasRepliedComment)
                            RepliedMessageBubble(message: message),
                          if (displayBottomStatuses)
                            Padding(
                              padding: !hasRepliedComment
                                  ? EdgeInsets.zero
                                  : const EdgeInsets.only(
                                      top: AppSpacing.xs,
                                    ),
                              child: TextBubble(
                                message: message,
                                isOnlyEmoji: message.message.isOnlyEmoji,
                              ),
                            )
                          else
                            TextMessageWidget(
                              text: message.message,
                              spacing: 12,
                              textStyle:
                                  context.bodyLarge?.apply(color: Colors.white),
                              child: MessageStatuses(
                                isEdited: isEdited,
                                message: message,
                              ),
                            ),
                          if (hasAttachments)
                            ParseAttachments(
                              message: message,
                              onReplyTap: onReplyTap,
                            ),
                        ],
                      ),
                    ),
                    if (displayBottomStatuses)
                      Positioned.fill(
                        right: AppSpacing.md,
                        bottom: AppSpacing.xs,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: MessageStatuses(
                            isEdited: isEdited,
                            message: message,
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class MessageStatuses extends StatelessWidget {
  const MessageStatuses({
    required this.isEdited,
    required this.message,
    super.key,
  });

  final Message message;
  final bool isEdited;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = message.sender?.id == user.id;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isEdited)
          Text(
            'edited',
            style: context.bodySmall?.apply(color: Colors.white),
          ),
        Text(
          message.createdAt.format(
            context,
            dateFormat: DateFormat.Hm,
          ),
          style: context.bodySmall?.apply(color: Colors.white),
        ),
        if (isMine) ...[
          if (message.isRead)
            Assets.icons.check.svg(
              height: AppSize.iconSizeSmall,
              width: AppSize.iconSizeSmall,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            )
          else
            const Icon(
              Icons.check,
              size: AppSize.iconSizeSmall,
              color: Colors.white,
            ),
        ],
      ].insertBetween(
        const SizedBox(width: AppSpacing.xs),
      ),
    );
  }
}

class TextMessageWidget extends SingleChildRenderObjectWidget {
  const TextMessageWidget({
    required this.text,
    required super.child,
    super.key,
    this.textStyle,
    this.spacing,
  });
  final String text;
  final TextStyle? textStyle;
  final double? spacing;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTextMessageWidget(text, textStyle, spacing);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTextMessageWidget renderObject,
  ) {
    renderObject
      ..text = text
      ..textStyle = textStyle
      ..spacing = spacing;
  }
}

class RenderTextMessageWidget extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderTextMessageWidget(
    String text,
    TextStyle? textStyle,
    double? spacing,
  )   : _text = text,
        _textStyle = textStyle,
        _spacing = spacing;
  String _text;
  TextStyle? _textStyle;
  double? _spacing;

  // With this constants you can modify the final result
  static const double _kOffset = 1.5;
  static const double _kFactor = .5;

  String get text => _text;
  set text(String value) {
    if (_text == value) return;
    _text = value;
    markNeedsLayout();
  }

  TextStyle? get textStyle => _textStyle;
  set textStyle(TextStyle? value) {
    if (_textStyle == value) return;
    _textStyle = value;
    markNeedsLayout();
  }

  double? get spacing => _spacing;
  set spacing(double? value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  TextPainter textPainter = TextPainter();

  @override
  void performLayout() {
    size = _performLayout(constraints: constraints, dry: false);

    (child!.parentData! as BoxParentData).offset = Offset(
      size.width - child!.size.width,
      size.height - child!.size.height / _kOffset,
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _performLayout(constraints: constraints, dry: true);
  }

  Size _performLayout({
    required BoxConstraints constraints,
    required bool dry,
  }) {
    textPainter = TextPainter(
      text: TextSpan(text: _text, style: _textStyle),
      textDirection: ui.TextDirection.ltr,
    );

    late final double spacing;

    if (_spacing == null) {
      spacing = constraints.maxWidth * 0.03;
    } else {
      spacing = _spacing!;
    }

    textPainter.layout(maxWidth: constraints.maxWidth);

    var height = textPainter.height;
    var width = textPainter.width;

    // Compute the LineMetrics of our textPainter
    final lines = textPainter.computeLineMetrics();

    // We are only interested in the last line's width
    final lastLineWidth = lines.last.width;

    if (child != null) {
      late final Size childSize;

      if (!dry) {
        child!.layout(
          BoxConstraints(maxWidth: constraints.maxWidth),
          parentUsesSize: true,
        );
        childSize = child!.size;
      } else {
        childSize =
            child!.getDryLayout(BoxConstraints(maxWidth: constraints.maxWidth));
      }

      if (lastLineWidth + spacing > constraints.maxWidth - child!.size.width) {
        height += childSize.height * _kFactor;
      } else if (lines.length == 1) {
        width += childSize.width + spacing;
      }
    }

    return Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    textPainter.paint(context.canvas, offset);
    final parentData = child!.parentData! as BoxParentData;
    context.paintChild(child!, offset + parentData.offset);
  }
}

class RepliedMessageBubble extends StatelessWidget {
  const RepliedMessageBubble({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final isMine = message.sender?.id == user.id;

    final repliedMessage = message.repliedMessage;
    final repliedMessageUsername = message.replyMessageUsername;
    final replyMessageAttachmentUrl = message.replyMessageAttachmentUrl;

    final accentColor = isMine ? Colors.white : const Color(0xff337eff);

    const imageHeight = 46.0;
    const imageWidth = 46.0;

    return Tappable(
      onTap: () {},
      animationEffect: TappableAnimationEffect.scale,
      scaleStrength: ScaleStrength.xxxxs,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: const [0.02, 0.02],
            colors: [accentColor, accentColor.withOpacity(.2)],
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: AppSpacing.sm - AppSpacing.xxs,
          titleAlignment: ListTileTitleAlignment.titleHeight,
          leading: replyMessageAttachmentUrl == null
              ? null
              : ImageAttachmentThumbnail(
                  image: Attachment(imageUrl: replyMessageAttachmentUrl),
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  borderRadius: 4,
                  withAdaptiveColors: false,
                ),
          title: Text(
            repliedMessageUsername ?? 'Unknown',
            style: context.bodyLarge
                ?.copyWith(color: accentColor, fontWeight: AppFontWeight.bold),
            overflow: TextOverflow.visible,
          ),
          subtitle: repliedMessage?.message.isEmpty ?? true
              ? null
              : Text(
                  repliedMessage!.message,
                  style: context.bodyMedium?.apply(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }
}

class SwipeableMessage extends StatelessWidget {
  const SwipeableMessage({
    required this.id,
    required this.child,
    required this.onSwiped,
    super.key,
  });

  final String id;
  final Widget child;
  final ValueSetter<SwipeDirection> onSwiped;

  @override
  Widget build(BuildContext context) {
    // The threshold after which the message is considered
    // swiped.
    const threshold = 0.2;

    const swipeDirection = SwipeDirection.endToStart;
    return Swipeable(
      key: ValueKey(id),
      direction: swipeDirection,
      swipeThreshold: threshold,
      onSwiped: onSwiped,
      backgroundBuilder: (context, details) {
        // The alignment of the swipe action.
        const alignment = Alignment.centerRight;

        // The progress of the swipe action.
        final progress = math.min(details.progress, threshold) / threshold;

        // The offset for the reply icon.
        var offset = Offset.lerp(
          const Offset(-24, 0),
          const Offset(12, 0),
          progress,
        )!;

        // If the message is mine, we need to flip the offset.
        // if (isMine) {
        offset = Offset(-offset.dx, -offset.dy);
        // }

        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: offset,
            child: Opacity(
              opacity: progress,
              child: SizedBox.square(
                dimension: 30,
                child: CustomPaint(
                  painter: AnimatedCircleBorderPainter(
                    progress: progress,
                    color: const Color(0xff1c1e22),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.reply_rounded,
                      size: ui.lerpDouble(0, 18, progress),
                      color: const Color(0xff337eff),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class BubbleBackground extends StatelessWidget {
  const BubbleBackground({
    required this.colors,
    super.key,
    this.child,
  });

  final List<Color> colors;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      isComplex: true,
      painter: BubblePainter(
        scrollable: Scrollable.of(context),
        bubbleContext: context,
        colors: colors,
      ),
      child: child,
    );
  }
}

class BubblePainter extends CustomPainter {
  BubblePainter({
    required ScrollableState scrollable,
    required BuildContext bubbleContext,
    required List<Color> colors,
  })  : _scrollable = scrollable,
        _bubbleContext = bubbleContext,
        _colors = colors,
        super(repaint: scrollable.position);

  final ScrollableState _scrollable;
  final BuildContext _bubbleContext;
  final List<Color> _colors;

  @override
  void paint(Canvas canvas, Size size) {
    final scrollableBox = _scrollable.context.findRenderObject()! as RenderBox;
    final scrollableRect = Offset.zero & scrollableBox.size;
    final bubbleBox = _bubbleContext.findRenderObject()! as RenderBox;

    final origin =
        bubbleBox.localToGlobal(Offset.zero, ancestor: scrollableBox);
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        scrollableRect.topCenter,
        scrollableRect.bottomCenter,
        _colors,
        _colors.length == 4 ? [0.0, 0.5, 0.75, 1.0] : [1.0],
        TileMode.clamp,
        Matrix4.translationValues(-origin.dx, -origin.dy, 0).storage,
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    return oldDelegate._scrollable != _scrollable ||
        oldDelegate._bubbleContext != _bubbleContext ||
        oldDelegate._colors != _colors;
  }
}

class MessageDateTimeSeparator extends StatelessWidget {
  const MessageDateTimeSeparator({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        decoration: const BoxDecoration(
          color: ui.Color.fromARGB(255, 58, 58, 70),
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
        child: Text(
          date.format(context, dateFormat: DateFormat.MMMMd),
          style: context.bodyMedium?.apply(color: Colors.white),
        ),
      ),
    );
  }
}
