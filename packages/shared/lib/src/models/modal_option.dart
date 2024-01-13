// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart' show Color, IconData, VoidCallback;

class ModalOption {
  final String name;
  final Color? nameColor;
  final IconData? icon;
  final VoidCallback? onTap;

  ModalOption({
    required this.name,
    this.icon,
    this.onTap,
    this.nameColor,
  });

  ModalOption copyWith({
    String? name,
    Color? nameColor,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return ModalOption(
      name: name ?? this.name,
      nameColor: nameColor ?? this.nameColor,
      icon: icon ?? this.icon,
      onTap: onTap ?? this.onTap,
    );
  }
}
