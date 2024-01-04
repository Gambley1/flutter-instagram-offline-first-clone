import 'package:insta_blocks/insta_blocks.dart';
import 'package:insta_blocks/src/models/post_author_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_large_block.g.dart';

/// {@template post_large_block}
/// A block which represents a large post block.
/// {@endtemplate}
@JsonSerializable()
class PostLargeBlock extends PostBlock {
  /// {@macro post_large_block}
  const PostLargeBlock({
    required super.id,
    required super.author,
    required super.publishedAt,
    required super.imageUrl,
    required super.imagesUrl,
    required super.caption,
    super.action,
    super.type = PostLargeBlock.identifier,
  });

  /// Converts a `Map<String, dynamic>` into a [PostLargeBlock] instance.
  factory PostLargeBlock.fromJson(Map<String, dynamic> json) =>
      _$PostLargeBlockFromJson(json);

  /// The large post block type identifier.
  static const identifier = '__post_large__';

  @override
  Map<String, dynamic> toJson() => _$PostLargeBlockToJson(this);
}
