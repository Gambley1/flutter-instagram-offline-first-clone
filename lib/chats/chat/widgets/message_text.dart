import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/parse_attachments.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

/// {@template streamMessageText}
/// The text content of a message.
/// {@endtemplate}
class MessageText extends StatelessWidget {
  /// {@macro message_text}
  const MessageText({
    required this.message,
    required this.isOnlyEmoji,
    required this.isMine,
    super.key,
    this.onMentionTap,
    this.onLinkTap,
  });

  /// Message whose text is to be displayed
  final Message message;

  /// The action to perform when a mention is tapped
  final ValueSetter<User>? onMentionTap;

  /// Whether the text contains only from emojies.
  final bool isOnlyEmoji;

  /// Whether the message send is from the current user.
  final bool isMine;

  /// The action to perform when a link is tapped
  final void Function(String)? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final text = message.message.replaceAll('\n', '\n\n').trim();

    final effectiveTextColor = switch ((isMine, context.isLight)) {
      (true, _) => AppColors.white,
      (false, true) => AppColors.black,
      (false, false) => AppColors.white,
    };

    return MarkdownBody(
      data: text,
      onTapLink: (
        String link,
        String? href,
        String title,
      ) async {
        if (onLinkTap != null) {
          onLinkTap!(link);
        } else {
          await launchURL(context, link);
        }
      },
      styleSheet: MarkdownStyleSheet.fromTheme(context.theme).copyWith(
        a: context.bodyLarge?.copyWith(
          height: 1,
          decoration: TextDecoration.underline,
          color: effectiveTextColor,
          decorationColor: effectiveTextColor,
        ),
        p: context.bodyLarge?.copyWith(
          height: 1,
          fontSize: isOnlyEmoji ? 42 : null,
          color: effectiveTextColor,
        ),
      ),
    );
  }
}

class TextMessageWidget extends SingleChildRenderObjectWidget {
  const TextMessageWidget({
    required this.text,
    required super.child,
    super.key,
    this.textStyle,
    this.spacing,
  });
  final String text;
  final TextStyle? textStyle;
  final double? spacing;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTextMessageWidget(text, textStyle, spacing);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTextMessageWidget renderObject,
  ) {
    renderObject
      ..text = text
      ..textStyle = textStyle
      ..spacing = spacing;
  }
}

class RenderTextMessageWidget extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderTextMessageWidget(
    String text,
    TextStyle? textStyle,
    double? spacing,
  )   : _text = text,
        _textStyle = textStyle,
        _spacing = spacing;
  String _text;
  TextStyle? _textStyle;
  double? _spacing;

  // With this constants you can modify the final result
  static const double _kOffset = 1.5;
  static const double _kFactor = .5;

  String get text => _text;
  set text(String value) {
    if (_text == value) return;
    _text = value;
    markNeedsLayout();
  }

  TextStyle? get textStyle => _textStyle;
  set textStyle(TextStyle? value) {
    if (_textStyle == value) return;
    _textStyle = value;
    markNeedsLayout();
  }

  double? get spacing => _spacing;
  set spacing(double? value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  TextPainter textPainter = TextPainter();

  @override
  void performLayout() {
    size = _performLayout(constraints: constraints, dry: false);

    (child!.parentData! as BoxParentData).offset = Offset(
      size.width - child!.size.width,
      size.height - child!.size.height / _kOffset,
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _performLayout(constraints: constraints, dry: true);
  }

  Size _performLayout({
    required BoxConstraints constraints,
    required bool dry,
  }) {
    textPainter = TextPainter(
      text: TextSpan(text: _text, style: _textStyle),
      textDirection: ui.TextDirection.ltr,
    );

    late final double spacing;

    if (_spacing == null) {
      spacing = constraints.maxWidth * 0.03;
    } else {
      spacing = _spacing!;
    }

    textPainter.layout(maxWidth: constraints.maxWidth);

    var height = textPainter.height;
    var width = textPainter.width;

    // Compute the LineMetrics of our textPainter
    final lines = textPainter.computeLineMetrics();

    // We are only interested in the last line's width
    final lastLineWidth = lines.last.width;

    if (child != null) {
      late final Size childSize;

      if (!dry) {
        child!.layout(
          BoxConstraints(maxWidth: constraints.maxWidth),
          parentUsesSize: true,
        );
        childSize = child!.size;
      } else {
        childSize =
            child!.getDryLayout(BoxConstraints(maxWidth: constraints.maxWidth));
      }

      if (lastLineWidth + spacing > constraints.maxWidth - child!.size.width) {
        height += childSize.height * _kFactor;
      } else if (lines.length == 1) {
        width += childSize.width + spacing;
      }
    }

    return Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    textPainter.paint(context.canvas, offset);
    final parentData = child!.parentData! as BoxParentData;
    context.paintChild(child!, offset + parentData.offset);
  }
}
