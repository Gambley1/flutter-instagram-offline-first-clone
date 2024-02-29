import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';

class TimeAgo extends StatelessWidget {
  const TimeAgo({required this.createdAt, this.short = false, super.key});

  final bool short;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Text(
      short
          ? BlockSettings().dateTimeTextDelegate.timeAgoShort(createdAt)
          : BlockSettings().dateTimeTextDelegate.timeAgo(createdAt),
      overflow: TextOverflow.visible,
      style: context.bodyMedium?.copyWith(color: AppColors.grey),
    );
  }
}
