import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:sprung/sprung.dart';

typedef LikesText = String Function(int count);

class LikesCount extends StatefulWidget {
  const LikesCount({
    required this.likesText,
    required this.likesCount,
    this.color,
    this.size,
    super.key,
  });

  final LikesText likesText;

  final Stream<int> likesCount;

  final Color? color;

  final double? size;

  @override
  State<LikesCount> createState() => _LikesCountState();
}

class _LikesCountState extends State<LikesCount>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<int>(
      stream: widget.likesCount,
      builder: (context, snapshot) {
        final count = snapshot.data;
        final isVisible = count != null && count != 0;
        // const text = 'Liked by emil.zulufov and 4 others';
        // final username = text.split(' ')[2];

        // String firstPart() {
        //   final newText = text.split(' ');
        //   final firstPart = newText.first;
        //   final secondPart = newText[1];
        //   return '$firstPart $secondPart ';
        // }

        // String secondPart() {
        //   final newText = text.split(' ');
        //   final firstPart = newText[3];
        //   final secondPart = newText[4];
        //   final thirdPart = newText[5];
        //   return '$firstPart $secondPart $thirdPart';
        // }

        return AnimatedVisibility(
          height: 25,
          duration: 250.ms,
          isVisible: isVisible,
          curve: Sprung.criticallyDamped,
          child: Tappable(
            animationEffect: TappableAnimationEffect.none,
            // child: Text.rich(
            //   TextSpan(
            //     children: [
            //       TextSpan(text: firstPart()),
            //       TextSpan(
            //         text: '$username ',
            //         style: context.bodyMedium
            //             ?.copyWith(fontWeight: AppFontWeight.bold),
            //       ),
            //       TextSpan(text: secondPart()),
            //     ],
            //   ),
            // ),
            child: Text(
              widget.likesText(count ?? 0),
              style: context.titleMedium?.copyWith(
                color: widget.color,
                fontSize: widget.size,
                overflow: TextOverflow.visible,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
