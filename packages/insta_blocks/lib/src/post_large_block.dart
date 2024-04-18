import 'package:insta_blocks/src/models/post_author_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/shared.dart';

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
    required super.createdAt,
    required super.media,
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
  PostLargeBlock copyWith({
    String? id,
    PostAuthor? author,
    DateTime? createdAt,
    List<Media>? media,
    String? caption,
    BlockAction? action,
  }) {
    return PostLargeBlock(
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
    if (other is! PostLargeBlock) return this;
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
  Map<String, dynamic> toJson() => _$PostLargeBlockToJson(this);
}
