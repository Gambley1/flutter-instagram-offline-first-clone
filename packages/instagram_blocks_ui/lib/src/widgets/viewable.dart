import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Viewable extends StatelessWidget {
  const Viewable({
    required this.itemKey,
    required this.child,
    super.key,
    this.onSeen,
    this.onUnseen,
  });

  final Key itemKey;
  final Widget child;
  final VoidCallback? onSeen;
  final VoidCallback? onUnseen;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: itemKey,
      onVisibilityChanged: (info) {
        if (!info.visibleBounds.isEmpty) {
          onSeen?.call();
          return;
        }
        onUnseen?.call();
      },
      child: child,
    );
  }
}
