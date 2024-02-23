// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';

class ModalOption {
  final String? name;
  final Color? nameColor;
  final Widget? icon;
  final IconData? iconData;
  final Widget? child;
  final BuildContextCallback? noAction;
  final String? actionTitle;
  final String? actionContent;
  final String? actionNoText;
  final String? actionYesText;
  final bool distractive;

  ModalOption({
    this.name,
    this.icon,
    this.iconData,
    this.child,
    VoidCallback? onTap,
    this.noAction,
    this.nameColor,
    this.distractive = false,
    this.actionTitle,
    this.actionContent,
    this.actionNoText,
    this.actionYesText,
  }) : _onTap = onTap;

  final VoidCallback? _onTap;

  void onTap(BuildContext context) => distractive
      ? context.confirmAction(
          title: actionTitle ?? name!,
          content: actionContent,
          noText: actionNoText ?? 'Cancel',
          yesText: actionYesText ?? 'Yes',
          noAction: noAction,
          fn: () => _onTap?.call(),
        )
      : _onTap?.call();

  Color? get distractiveColor => distractive ? AppColors.red : null;

  ModalOption copyWith({
    String? name,
    Color? nameColor,
    Widget? icon,
    IconData? iconData,
    Widget? child,
    BuildContextCallback? noAction,
    String? actionTitle,
    String? actionContent,
    String? actionNoText,
    String? actionYesText,
    bool? distractive,
  }) {
    return ModalOption(
      name: name ?? this.name,
      nameColor: nameColor ?? this.nameColor,
      icon: icon ?? this.icon,
      iconData: iconData ?? this.iconData,
      child: child ?? this.child,
      noAction: noAction ?? this.noAction,
      actionTitle: actionTitle ?? this.actionTitle,
      actionContent: actionContent ?? this.actionContent,
      actionNoText: actionNoText ?? this.actionNoText,
      actionYesText: actionYesText ?? this.actionYesText,
      distractive: distractive ?? this.distractive,
    );
  }
}
