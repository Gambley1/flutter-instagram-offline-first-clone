import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'post_options_settings.freezed.dart';

/// {@template post_options_settings}
/// Class representing options for post settings.
/// {@endtemplate}
@freezed
class PostOptionsSettings with _$PostOptionsSettings {
  /// {@macro post_options_settings}
  const PostOptionsSettings._();

  /// {@macro post_options_settings.owner}
  const factory PostOptionsSettings.owner({
    required ValueSetter<String> onPostDelete,
  }) = Owner;

  /// {@macro post_options_settings.viewer}
  const factory PostOptionsSettings.viewer() = Viewer;

  /// The list of options that are available only for owner of the post.
  /// E.g. delete, update, etc.
  List<ModalOption> ownerOptions({
    required VoidCallback onPostEditTap,
    required VoidCallback onPostDeleteTap,
  }) =>
      <ModalOption>[
        ModalOption(
          name: 'Edit',
          icon: Icons.edit,
          onTap: onPostEditTap,
        ),
        ModalOption(
          name: 'Delete',
          distractiveActionTitle: 'Delete post',
          child: Assets.icons.trash.svg(
            colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
          ),
          distractive: true,
          onTap: onPostDeleteTap,
        ),
      ];

  /// The list of options that are available only for owner of the post.
  /// E.g. don't show posts from posts's author, block owner of post, etc.
  List<ModalOption> viewerOptions({
    required VoidCallback onPostDontShowAgainTap,
    required VoidCallback onPostBlockAuthorTap,
  }) =>
      <ModalOption>[
        ModalOption(
          name: "Don't show again",
          icon: Icons.remove_circle_outline_sharp,
          onTap: onPostDontShowAgainTap,
        ),
        ModalOption(
          name: 'Block post author',
          icon: Icons.block,
          distractive: true,
          onTap: onPostBlockAuthorTap,
        ),
      ];
}
