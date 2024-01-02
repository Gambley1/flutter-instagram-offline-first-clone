import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Renders a widget containing a progress indicator that calls
/// [onPresented] when the item becomes visible.
class FeedLoaderItem extends StatefulWidget {
  const FeedLoaderItem({super.key, this.onPresented});

  /// A callback performed when the widget is presented.
  final VoidCallback? onPresented;

  @override
  State<FeedLoaderItem> createState() => _FeedLoaderItemState();
}

class _FeedLoaderItemState extends State<FeedLoaderItem> {
  @override
  void initState() {
    super.initState();
    Future.delayed(1.seconds, () => widget.onPresented?.call());
  }

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
