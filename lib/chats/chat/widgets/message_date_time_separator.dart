import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

class MessageDateTimeSeparator extends StatelessWidget {
  const MessageDateTimeSeparator({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.dark.withOpacity(.7),
          borderRadius: const BorderRadius.all(Radius.circular(22)),
        ),
        child: Text(
          date.format(context, dateFormat: DateFormat.MMMMd),
          style: context.bodyMedium?.apply(color: AppColors.white),
        ),
      ),
    );
  }
}
