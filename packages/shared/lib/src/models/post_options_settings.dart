import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
}
