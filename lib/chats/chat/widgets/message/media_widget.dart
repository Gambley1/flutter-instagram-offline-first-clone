import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/chat_context.dart';

class MediaWrapper extends StatelessWidget {
  const MediaWrapper({
    required this.child,
    required this.width,
    required this.height,
    required this.type,
    super.key,
  });

  final Widget child;
  final double width;
  final double height;
  final MediaType type;

  @override
  Widget build(BuildContext context) {
    final chatContext = ChatContext.of(context);

    final mediaConstraint = chatContext.mediaConstraints[type];
    return Media(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: mediaConstraint!.width,
          maxHeight: mediaConstraint.height,
        ),
        child: AspectRatio(
          aspectRatio: width / height,
          child: child,
        ),
      ),
    );
  }
}

// widget marker for MessageContent
class Media extends SingleChildRenderObjectWidget {
  const Media({
    required Widget super.child,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => MediaRender();
}

class MediaRender extends RenderProxyBox {}
