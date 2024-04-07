import 'dart:convert';

import 'package:insta_blocks/src/models/post_author_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/shared.dart';

part 'post_small_block.g.dart';

/// {@template post_small_block}
/// A block which represents a small post block.
/// {@endtemplate}
@JsonSerializable()
class PostSmallBlock extends PostBlock {
  /// {@macro post_small_block}
  const PostSmallBlock({
    required super.id,
    required super.author,
    required super.createdAt,
    required super.media,
    required super.caption,
    super.action,
    super.type = PostSmallBlock.identifier,
  });

  /// Converts a `Map<String, dynamic>` into a [PostSmallBlock] instance.
  factory PostSmallBlock.fromJson(Map<String, dynamic> json) =>
      _$PostSmallBlockFromJson(json);

  /// Converts a `Map<String, dynamic>` into a [PostSmallBlock] instance.
  factory PostSmallBlock.fromShared(Map<String, dynamic> shared) =>
      PostSmallBlock(
        id: shared['shared_post_id'] as String,
        author: PostAuthor.fromShared(shared),
        createdAt: DateTime.parse(shared['shared_post_created_at'] as String),
        media: shared['shared_post_media'] == null
            ? []
            : List<Map<String, dynamic>>.from(
                jsonDecode(shared['shared_post_media'] as String) as List,
              ).map(Media.fromJson).toList(),
        caption: shared['shared_post_caption'] as String? ?? '',
      );

  /// The small post block type identifier.
  static const identifier = '__post_small__';

  @override
  PostSmallBlock copyWith({
    String? id,
    PostAuthor? author,
    DateTime? createdAt,
    List<Media>? media,
    String? caption,
    BlockAction? action,
  }) {
    return PostSmallBlock(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      media: media ?? this.media,
      caption: caption ?? this.caption,
      action: action ?? this.action,
    );
  }

  @override
  PostBlock merge({PostBlock? other}) {
    if (other is! PostSmallBlock) return this;
    return copyWith(
      id: other.id,
      author: other.author,
      createdAt: other.createdAt,
      media: other.media,
      caption: other.caption,
      action: other.action,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$PostSmallBlockToJson(this);
}
