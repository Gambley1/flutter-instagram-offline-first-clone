import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:shared/shared.dart';
import 'package:shared/src/models/date_time_converter.dart';
import 'package:shared/src/models/user_converter.dart';
import 'package:user_repository/user_repository.dart';

part 'post.g.dart';

@immutable
@JsonSerializable()

/// {@template post}
/// A post model.
/// {@endtemplate}
class Post {
  /// {@macro post}
  const Post({
    required this.id,
    required this.author,
    required this.caption,
    required this.createdAt,
    this.media = const [],
    this.updatedAt,
  });

  /// Converts a `Map<String, dynamic>` into a [Post] instance.
  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(
        json
          ..putIfAbsent(
            'author',
            () => {
              'id': json['user_id'],
              'avatar_url': json['avatar_url'],
              'username': json['username'],
            },
          ),
      );

  /// The post unique identifier.
  final String id;

  /// The author of the post.
  @UserConverter()
  final User author;

  /// The post caption.
  final String caption;

  /// The date time when the post was created.
  @DateTimeConverter()
  final DateTime createdAt;

  /// The date time(if updated) when the post was updated.
  final DateTime? updatedAt;

  /// The list of media of the post.
  @ListMediaConverterFromDb()
  final List<Media> media;

  /// Converts current [Post] instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() => _$PostToJson(this);
}
