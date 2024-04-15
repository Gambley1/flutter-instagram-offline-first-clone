import 'package:flutter/widgets.dart';

class ChatContext extends StatelessWidget {
  const ChatContext({required this.data, required this.child, super.key});

  final ChatContextData data;

  final Widget child;

  static ChatContextData of(BuildContext context) {
    final inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<_InheritedContext>();
    final theme = inheritedTheme!.theme.data;
    return theme;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedContext(
      theme: this,
      child: child,
    );
  }
}

enum MediaType { video, photo, animation }

class ChatContextData {
  const ChatContextData.raw({
    required this.maxWidth,
    required this.width,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.mediaConstraints,
  });

  factory ChatContextData.desktop({
    required double width,
    required double maxWidth,
  }) =>
      ChatContextData.raw(
        width: width,
        horizontalPadding: 8,
        verticalPadding: 4,
        maxWidth: maxWidth,
        mediaConstraints: <MediaType, Size>{
          MediaType.video: const Size(double.infinity, 450),
          MediaType.photo: const Size(double.infinity, 450),
          MediaType.animation: const Size(300, 300),
        },
      );

  final double maxWidth;
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  final Map<MediaType, Size> mediaConstraints;
}

class _InheritedContext extends InheritedTheme {
  const _InheritedContext({
    required this.theme,
    required super.child,
  });

  final ChatContext theme;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ChatContext(data: theme.data, child: child);
  }

  @override
  bool updateShouldNotify(_InheritedContext old) =>
      theme.data != old.theme.data;
}
