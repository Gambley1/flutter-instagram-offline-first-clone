import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/bubble/bubble_border_widget.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/bubble/bubble_clipper.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/bubble/bubble_render_box.dart';

class Bubble extends StatefulWidget {
  const Bubble({
    required this.child,
    required this.radius,
    required this.borderColor,
    super.key,
  });

  final Widget child;
  final double radius;
  final Color borderColor;

  @override
  State<Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> implements BorderPathProvider {
  late final BubbleClipper _clipper = BubbleClipper(radius: widget.radius);

  @override
  Widget build(BuildContext context) {
    return BubbleBorderWidget(
      borderPathProvider: this,
      color: widget.borderColor,
      child: ClipPath(
        clipper: BubbleClipper(
          radius: widget.radius,
        ),
        child: widget.child,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant Bubble oldWidget) {
    if (oldWidget.radius != widget.radius) {
      _clipper.radius = widget.radius;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Path getPath(Size size) => _clipper.getClip(size);
}
