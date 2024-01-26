import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class TimeAgo extends StatelessWidget {
  const TimeAgo({required this.createdAt, super.key});

  final String createdAt;

  @override
  Widget build(BuildContext context) {
    return Text(
      createdAt,
      style: context.bodyMedium?.copyWith(
        color: Colors.grey.shade500,
      ),
    );
  }
}
