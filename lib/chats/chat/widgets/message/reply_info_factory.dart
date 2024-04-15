import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/chat_context.dart';

class ReplyInfoFactory {
  const ReplyInfoFactory();

  Widget? createFromMessageModel(BuildContext context, ReplyInfo replyInfo) {
    return _Decoration(child: _Body(replyInfo: replyInfo));
  }
}

class _Painter extends CustomPainter {
  _Painter({required Color lineColor})
      : _paint = Paint()
          ..color = lineColor
          ..strokeWidth = 2;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      const Offset(horOffsetX, 0),
      Offset(horOffsetX, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) {
    return _paint != oldDelegate._paint;
  }

  static const double horOffsetX = 8;
}

class _Decoration extends StatelessWidget {
  const _Decoration({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final chatContextData = ChatContext.of(context);
    return Padding(
      padding: EdgeInsets.only(
        right: chatContextData.horizontalPadding,
        bottom: chatContextData.verticalPadding,
      ),
      child: CustomPaint(
        painter: _Painter(lineColor: AppColors.deepBlue),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: child,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.replyInfo,
  });

  final ReplyInfo replyInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                replyInfo.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium,
              ),
              Text(
                replyInfo.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FlexibleSpaceFillingWidget extends StatelessWidget {
  const FlexibleSpaceFillingWidget({
    required this.child,
    super.key,
    this.minWidth = 0.0,
  });

  final Widget child;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 0, // Don't consume any flex space initially
      child: Row(
        children: [
          Expanded(
            child: child,
          ),
          const Spacer(), // Fills remaining space
        ],
      ),
    );
  }
}

class ReplyInfo {
  const ReplyInfo({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}
