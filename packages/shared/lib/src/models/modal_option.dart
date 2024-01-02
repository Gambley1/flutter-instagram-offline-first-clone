// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart' show IconData, VoidCallback;

class ModalOption {
  final String name;
  final IconData? icon;
  final VoidCallback? onTap;

  ModalOption({
    required this.name,
    this.icon,
    this.onTap,
  });

  ModalOption copyWith({
    String? name,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return ModalOption(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      onTap: onTap ?? this.onTap,
    );
  }
}
