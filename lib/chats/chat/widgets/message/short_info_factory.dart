import 'dart:ui' as ui show PlaceholderAlignment;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

class ShortInfoFactory {
  const ShortInfoFactory();

  Widget create({
    required BuildContext context,
    required bool isOutgoing,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return Padding(
      padding: padding,
      child: _createBase(context, isOutgoing),
    );
  }

  Widget _createBase(
    BuildContext context,
    bool isOutgoing,
  ) {
    final caption = context.bodySmall;
    final iconSize = caption!.fontSize! * 1.4;
    return RichText(
      text: TextSpan(
        style: caption,
        children: <InlineSpan>[
          TextSpan(
            children: <InlineSpan>[
              WidgetSpan(
                alignment: ui.PlaceholderAlignment.middle,
                baseline: TextBaseline.ideographic,
                child: Icon(
                  Icons.remove_red_eye,
                  color: caption.color,
                  size: iconSize,
                ),
              ),
              const TextSpan(text: ' ${4000}\u0009\u0009'),
            ],
          ),
          const TextSpan(
            text: 'edited ',
          ),
          TextSpan(
            text: '${DateTime.now().subtract(21.minutes).format(
                  context,
                  dateFormat: DateFormat.Hm,
                )} ',
            style: context.bodySmall,
          ),
          WidgetSpan(
            child: Icon(
              Icons.done_all,
              color: caption.color,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}
