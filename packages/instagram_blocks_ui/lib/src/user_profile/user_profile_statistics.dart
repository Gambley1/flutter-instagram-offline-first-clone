import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class UserProfileStatistic extends StatelessWidget {
  const UserProfileStatistic({
    required this.name,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String name;
  final Stream<int> value;
  final VoidCallback onTap;

  static const _statitisticsPadding =
      EdgeInsets.symmetric(horizontal: 6, vertical: 6);

  @override
  Widget build(BuildContext context) {
    return Tappable(
      animationEffect: TappableAnimationEffect.none,
      onTap: onTap,
      child: Padding(
        padding: _statitisticsPadding,
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 99),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatisticValue(value: value),
              Text(
                name,
                style: context.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticValue extends StatelessWidget {
  const StatisticValue({required this.value, super.key});

  final Stream<int> value;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: value,
      builder: (context, snapshot) {
        final value = snapshot.data;
        return Text(
          value == null ? '0' : value.compact(context),
          style: context.titleLarge?.copyWith(fontWeight: AppFontWeight.bold),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
