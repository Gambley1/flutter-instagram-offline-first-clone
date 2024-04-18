import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Viewable extends StatelessWidget {
  const Viewable({
    required this.itemKey,
    required this.child,
    this.isVisible = _defaultIsVisible,
    super.key,
    this.onSeen,
    this.onUnseen,
  });

  final Key itemKey;
  final Widget child;
  final bool Function(Rect visibleBounds) isVisible;
  final VoidCallback? onSeen;
  final VoidCallback? onUnseen;

  static bool _defaultIsVisible(Rect visibleBounds) => !visibleBounds.isEmpty;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: itemKey,
      onVisibilityChanged: (info) {
        if (isVisible(info.visibleBounds)) {
          return onSeen?.call();
        }
        return onUnseen?.call();
      },
      child: child,
    );
  }
}
