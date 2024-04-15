import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message_wrap.dart';
import 'package:shared/shared.dart' as s;

class MessageText extends StatelessWidget {
  const MessageText({required this.text, required this.shortInfo, super.key});

  final s.CustomRichText text;
  final Widget shortInfo;

  @override
  Widget build(BuildContext context) {
    return MessageWrap(
      wrapGravity: WrapGravity.top,
      content: Text.rich(text.toInlineSpan(context)),
      shortInfo: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: shortInfo,
      ),
    );
  }
}

extension RichTextExt on s.CustomRichText {
  InlineSpan toInlineSpan(BuildContext context) {
    return TextSpan(
      children: entities.map((s.Entity e) {
        return e.types.first.map(
          planeText: (_) {
            return TextSpan(text: e.text);
          },
          textUrl: (s.TextUrl value) {
            return TextSpan(
              text: e.text,
              style: const TextStyle(
                color: AppColors.deepBlue,
                decoration: TextDecoration.underline,
              ),
            );
          },
          customEmoji: (s.CustomEmoji value) {
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: CustomEmojiContainer(
                emoji: e.text,
                style: DefaultTextStyle.of(context).style,
                child: const Placeholder(),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class CustomEmojiContainer extends StatelessWidget {
  const CustomEmojiContainer({
    required this.emoji,
    required this.child,
    required this.style,
    super.key,
  });

  final String emoji;
  final Widget child;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return _EmojiRenderObject(
      children: <Widget>[
        Text('🚫', style: style),
        child,
      ],
    );
  }
}

class _EmojiRenderObject extends MultiChildRenderObjectWidget {
  const _EmojiRenderObject({super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _BodyRenderBox();
  }
}

class _BodyRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EmojiParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EmojiParentData> {
  _BodyRenderBox();

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _EmojiParentData) {
      child.parentData = _EmojiParentData();
    }
  }

  @override
  void performLayout() {
    assert(childCount == 2, '');
    final renderParagraph = firstChild!;
    assert(renderParagraph is RenderParagraph, '');
    renderParagraph.layout(constraints, parentUsesSize: true);

    final newSize = constraints.constrain(
      Size(renderParagraph.size.height, renderParagraph.size.height),
    );
    size = newSize;

    lastChild!.layout(BoxConstraints.tight(newSize));

    getParentData(renderParagraph).offset = Offset(
      (renderParagraph.size.height - renderParagraph.size.width) / 2,
      0,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = lastChild!;
    final childParentData = getParentData(child);
    context.paintChild(child, childParentData.offset + offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  _EmojiParentData getParentData(RenderBox box) =>
      box.parentData! as _EmojiParentData;
}

class _EmojiParentData extends ContainerBoxParentData<RenderBox> {}
