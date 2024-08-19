import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class UserProfileStatistic extends StatelessWidget {
  const UserProfileStatistic({
    required this.name,
    required this.value,
    this.onTap,
    super.key,
  });

  final String name;
  final int value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatisticValue(value: value),
          Text(
            name.toLowerCase(),
            style: context.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class StatisticValue extends StatelessWidget {
  const StatisticValue({required this.value, super.key});

  final int value;

  @override
  Widget build(BuildContext context) {
    final applyLargeFont = value <= 9999;
    final effectiveTextStyle = applyLargeFont
        ? context.titleLarge?.copyWith(fontSize: 20)
        : context.bodyLarge;

    return Text(
      value.compactShort(context),
      style: effectiveTextStyle?.copyWith(fontWeight: AppFontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
