// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:user_repository/user_repository.dart';

enum StoryContentType {
  image,
  video;

  String toJson() => name;
  static StoryContentType fromJson(Map<String, dynamic> json) =>
      values.byName(json['content_type'] as String);
}

extension StoryContentTypeConverter on String {
  StoryContentType get toStoryContentType =>
      StoryContentType.values.byName(this);
}

List<Story> fromListJson(String json) =>
    List<Map<String, dynamic>>.from(jsonDecode(json) as List)
        .map(Story.fromJson)
        .toList();

/// {@template story}
/// The representation of the Instagram user's `story` model.
/// {@endtemplate}
@immutable
class Story extends Equatable {
  /// {@macro story}
  const Story({
    required this.id,
    required this.contentUrl,
    required this.createdAt,
    required this.expiresAt,
    this.contentType = StoryContentType.image,
    this.duration,
    this.author = User.anonymous,
    this.seen = false,
  });

  /// Converts the `Map<String, dynamic>` into a [Story] instance.
  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        contentType: (json['content_type'] as String).toStoryContentType,
        contentUrl: json['content_url'] as String,
        author: json['user_id'] == null ? User.anonymous : User.fromJson(json),
        duration: json['duration'] as int?,
        createdAt: DateTime.parse(json['created_at'] as String),
        expiresAt: DateTime.parse(json['expires_at'] as String),
        seen: json['seen'] as bool? ?? false,
      );

  /// The identifier of the story.
  final String id;

  /// The author of the story.
  final User author;

  /// The content type of the story.
  final StoryContentType contentType;

  /// The url to the content of the story.
  final String contentUrl;

  /// The duration of the story in seconds.
  final int? duration;

  /// The date time when the story was created.
  final DateTime createdAt;

  /// The date time when the story expires, commonly 1 day from [createdAt].
  final DateTime expiresAt;

  /// Whether the story was seen by the user.
  final bool seen;

  /// Converts the [Story] instance into a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() => {
        'id': id,
        'content_type': contentType.toJson(),
        'content_url': contentUrl,
        if (!author.isAnonymous) 'author': author,
        if (duration != null) 'duration': duration,
        'created_at': createdAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'seen': seen,
      };

  static Story empty = Story(
    id: '',
    contentUrl: '',
    createdAt: DateTime.now(),
    expiresAt: DateTime.now(),
  );

  Story copyWith({
    String? id,
    User? author,
    StoryContentType? contentType,
    String? contentUrl,
    int? duration,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? seen,
  }) =>
      Story(
        id: id ?? this.id,
        author: author ?? this.author,
        contentType: contentType ?? this.contentType,
        contentUrl: contentUrl ?? this.contentUrl,
        duration: duration ?? this.duration,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
        seen: seen ?? this.seen,
      );

  Story merge({
    required Story other,
    bool? seen,
  }) =>
      copyWith(
        id: other.id,
        author: other.author,
        contentType: other.contentType,
        contentUrl: other.contentUrl,
        createdAt: other.createdAt,
        expiresAt: other.expiresAt,
        seen: seen,
      );

  @override
  List<Object?> get props =>
      [id, contentType, contentUrl, createdAt, expiresAt, seen];
}
