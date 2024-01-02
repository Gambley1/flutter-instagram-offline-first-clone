import 'package:insta_blocks/insta_blocks.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_sponsored_block.g.dart';

/// {@template post_sponsored_block}
/// A block which represents a sponsored post block.
/// {@endtemplate}
@JsonSerializable()
class PostSponsoredBlock extends PostBlock {
  /// {@macro post_sponsored_block}
  const PostSponsoredBlock({
    required super.id,
    required super.author,
    required super.publishedAt,
    required super.imageUrl,
    required super.imagesUrl,
    required super.caption,
    super.action,
    super.type = PostSponsoredBlock.identifier,
  });

  /// Converts a `Map<String, dynamic>` into a [PostSponsoredBlock] instance.
  factory PostSponsoredBlock.fromJson(Map<String, dynamic> json) =>
      _$PostSponsoredBlockFromJson(json);

  /// The sponsored post block type identifier.
  static const identifier = '__post_sponsored__';

  @override
  Map<String, dynamic> toJson() => _$PostSponsoredBlockToJson(this);
}
