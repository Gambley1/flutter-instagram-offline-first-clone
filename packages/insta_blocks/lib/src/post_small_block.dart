import 'dart:convert';

import 'package:insta_blocks/insta_blocks.dart';
import 'package:json_annotation/json_annotation.dart';

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
    required super.publishedAt,
    required super.imageUrl,
    required super.imagesUrl,
    required super.caption,
    super.action,
    super.type = PostSmallBlock.identifier,
  });

  /// Converts a `Map<String, dynamic>` into a [PostSmallBlock] instance.
  factory PostSmallBlock.fromJson(Map<String, dynamic> json) =>
      _$PostSmallBlockFromJson(json);

  /// Converts a [shared] `Map<String, dynamic>` into a [PostSmallBlock]
  /// instance.
  factory PostSmallBlock.fromShared(Map<String, dynamic> shared) =>
      PostSmallBlock(
        id: shared['shared_post_id'] as String,
        author: PostAuthor.fromShared(shared),
        publishedAt:
            DateTime.parse(shared['shared_post_published_at'] as String),
        imageUrl: shared['shared_post_image_url'] as String,
        imagesUrl: shared['shared_post_images_url'] == null
            ? []
            : (jsonDecode(shared['shared_post_images_url'] as String) as List)
                .cast<String>(),
        caption: shared['shared_post_caption'] as String,
      );

  /// The small post block type identifier.
  static const identifier = '__post_small__';

  @override
  Map<String, dynamic> toJson() => _$PostSmallBlockToJson(this);
}
