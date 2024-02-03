// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart'
    show Color, Colors, IconData, VoidCallback, Widget;
import 'package:flutter/widgets.dart';

class ModalOption {
  final String name;
  final Color? nameColor;
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onTap;
  final String? distractiveActionTitle;
  final String? distractiveActionNoText;
  final String? distractiveActionYesText;
  final bool distractive;

  ModalOption({
    required this.name,
    this.icon,
    this.child,
    this.onTap,
    this.nameColor,
    this.distractive = false,
    this.distractiveActionTitle,
    this.distractiveActionNoText,
    this.distractiveActionYesText,
  });

  Color? get distractiveColor => distractive ? Colors.red : null;

  void distractiveCallback(BuildContext context) => distractive
      ? context
          .showConfirmationDialog(
          noText: distractiveActionNoText ?? 'Cancel',
          yesText: distractiveActionYesText ?? name,
          title: distractiveActionTitle ??
              'Are you sure to ${name.toLowerCase()}?',
        )
          .then((confirmed) {
          if (confirmed == null) return;
          if (!confirmed) return;
          onTap?.call();
        })
      : onTap?.call();

  ModalOption copyWith({
    String? name,
    Color? nameColor,
    IconData? icon,
    Widget? child,
    VoidCallback? onTap,
    String? distractiveActionTitle,
    String? distractiveActionNoText,
    String? distractiveActionYesText,
    bool? distractive,
  }) {
    return ModalOption(
      name: name ?? this.name,
      nameColor: nameColor ?? this.nameColor,
      icon: icon ?? this.icon,
      child: child ?? this.child,
      onTap: onTap ?? this.onTap,
      distractiveActionTitle:
          distractiveActionTitle ?? this.distractiveActionTitle,
      distractiveActionNoText:
          distractiveActionNoText ?? this.distractiveActionNoText,
      distractiveActionYesText:
          distractiveActionYesText ?? this.distractiveActionYesText,
      distractive: distractive ?? this.distractive,
    );
  }
}
