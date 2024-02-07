import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:sprung/sprung.dart';

typedef CommentsText = String Function(int count);

/// {@template comments_count}
/// Renders the comment count with animation.
/// {@endtemplate}
class CommentsCount extends StatefulWidget {
  const CommentsCount({
    required this.count,
    required this.onTap,
    required this.commentsText,
    super.key,
  });

  final CommentsText commentsText;
  final int count;
  final VoidCallback onTap;

  @override
  State<CommentsCount> createState() => _CommentsCountState();
}

class _CommentsCountState extends State<CommentsCount>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final count = widget.count;
    final isVisible = count != 0;

    return AnimatedVisibility(
      height: 25,
      duration: 250.ms,
      isVisible: isVisible,
      curve: Sprung.criticallyDamped,
      child: Tappable(
        animationEffect: TappableAnimationEffect.none,
        onTap: widget.onTap,
        child: Text(
          widget.commentsText(count),
          style: context.bodyLarge?.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
