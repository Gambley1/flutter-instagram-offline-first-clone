import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:sprung/sprung.dart';

class LikesCount extends StatefulWidget {
  const LikesCount({
    required this.count,
    this.short = false,
    this.textBuilder,
    this.color,
    this.size,
    this.hideCount = true,
    super.key,
  });

  final int count;
  final bool short;
  final Color? color;
  final double? size;
  final Widget? Function(int count)? textBuilder;
  final bool hideCount;

  @override
  State<LikesCount> createState() => _LikesCountState();
}

class _LikesCountState extends State<LikesCount>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final count = widget.count;
    final isVisible = !widget.hideCount || count != 0;

    return AnimatedVisibility(
      height: 25,
      duration: 250.ms,
      isVisible: isVisible,
      curve: Sprung.criticallyDamped,
      child: widget.textBuilder?.call(count != 0 ? count - 1 : 0) ??
          Text(
            widget.short
                ? context.l10n.likesCountTextShort(count)
                : context.l10n.likesCountText(count),
            style: context.titleMedium?.copyWith(
              color: widget.color,
              fontSize: widget.size,
              overflow: TextOverflow.visible,
            ),
            textAlign: TextAlign.center,
          ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
