import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class TimeAgo extends StatelessWidget {
  const TimeAgo({required this.publishedAt, super.key});

  final String publishedAt;

  @override
  Widget build(BuildContext context) {
    return Text(
      publishedAt,
      style: context.bodyMedium?.copyWith(
        color: Colors.grey.shade500,
      ),
    );
  }
}
