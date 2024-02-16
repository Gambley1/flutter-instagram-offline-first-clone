// ignore_for_file: public_member_api_docs
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

final kTransparentImage = Uint8List.fromList(
  <int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
  ],
);

/// Navigation bar items
List<NavBarItem> mainNavigationBarItems({
  required String homeLabel,
  required String searchLabel,
  required String createMediaLabel,
  required String reelsLabel,
  required String userProfileLabel,
  required Widget userProfileAvatar,
}) =>
    <NavBarItem>[
      NavBarItem(icon: Icons.home_filled, label: homeLabel),
      NavBarItem(icon: Icons.search, label: searchLabel),
      NavBarItem(icon: Icons.add_box_outlined, label: createMediaLabel),
      NavBarItem(icon: Icons.video_collection_outlined, label: reelsLabel),
      NavBarItem(child: userProfileAvatar, label: userProfileLabel),
    ];

class NavBarItem {
  NavBarItem({
    this.icon,
    this.label,
    this.child,
  });

  final String? label;
  final Widget? child;
  final IconData? icon;

  String? get tooltip => label;
}

class GradientColor {
  const GradientColor({required this.hex, this.opacity});

  final String hex;
  final double? opacity;
}

enum PremiumGradient {
  fl0(
    colors: [
      GradientColor(hex: '842CD7'),
      GradientColor(hex: '21F5F1', opacity: .8),
    ],
    stops: [0, 1],
  ),
  telegram(
    colors: [
      GradientColor(hex: '6C93FF'),
      GradientColor(hex: '976FFF'),
      GradientColor(hex: 'DF69D1'),
    ],
    stops: [0, .5, 1],
  );

  const PremiumGradient({
    required this.colors,
    required this.stops,
  });

  final List<GradientColor> colors;
  final List<double> stops;
}

List<String> get commentEmojies =>
    ['❤', '🙌', '🔥', '👏🏻', '😢', '😍', '😮', '😂'];

List<ModalOption> createMediaModalOptions({
  required String reelLabel,
  required String postLabel,
  required String storyLabel,
  required BuildContext context,
  required void Function(String route, {Object? extra}) goTo,
  required bool enableStory,
  required VoidCallback onCreateReelTap,
  Object? storyExtra,
}) =>
    <ModalOption>[
      ModalOption(
        name: reelLabel,
        icon: Icons.video_collection_outlined,
        onTap: onCreateReelTap,
      ),
      ModalOption(
        name: postLabel,
        icon: Icons.outbox_outlined,
        onTap: () => goTo('create_post'),
      ),
      if (enableStory)
        ModalOption(
          name: storyLabel,
          icon: Icons.cameraswitch_outlined,
          onTap: () => goTo('create_stories', extra: storyExtra),
        ),
    ];

List<ModalOption> subscriberModalOptions({
  required String cancelSubscriptionLabel,
  required VoidCallback cancelSubscription,
  ValueSetter<String>? goTo,
}) =>
    <ModalOption>[
      ModalOption(
        name: cancelSubscriptionLabel,
        onTap: cancelSubscription,
      ),
    ];
