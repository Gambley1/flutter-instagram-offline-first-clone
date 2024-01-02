import 'package:insta_blocks/src/models/models.dart';
import 'package:json_annotation/json_annotation.dart';

/// {@template block_action_converter}
/// A [JsonConverter] that supports (de)serializing a [PostAuthor].
/// {@endtemplate}
class PostAuthorConverter
    implements JsonConverter<PostAuthor, Map<String, dynamic>> {
  /// {@macro post_author_converter}
  const PostAuthorConverter();
  @override
  PostAuthor fromJson(Map<String, dynamic> json) => PostAuthor.fromJson(json);

  @override
  Map<String, dynamic> toJson(PostAuthor object) => object.toJson();
}
