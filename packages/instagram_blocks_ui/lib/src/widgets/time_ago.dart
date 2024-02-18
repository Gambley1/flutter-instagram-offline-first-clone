import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/time_ago.dart';

class TimeAgo extends StatelessWidget {
  const TimeAgo({required this.createdAt, this.short = false, super.key});

  final bool short;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Text(
      short ? createdAt.timeAgoShort(context) : createdAt.timeAgo(context),
      style: context.bodyMedium?.copyWith(color: Colors.grey.shade500),
    );
  }
}
