import 'package:insta_blocks/src/models/models.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/shared.dart';

part 'post_reel_block.g.dart';

/// {@template post_reel_block}
/// A block which represents a reel post block.
/// {@endtemplate}
@JsonSerializable()
class PostReelBlock extends PostBlock {
  /// {@macro post_reel_block}
  const PostReelBlock({
    required super.id,
    required super.author,
    required super.createdAt,
    required super.media,
    required super.caption,
    super.action,
    super.type = PostReelBlock.identifier,
  });

  /// Converts a `Map<String, dynamic>` into a [PostReelBlock] instance.
  factory PostReelBlock.fromJson(Map<String, dynamic> json) =>
      _$PostReelBlockFromJson(json);

  /// The large post block type identifier.
  static const identifier = '__post_reel__';

  /// The video media of the [PostReelBlock]'s reel.
  VideoMedia? get reel => media.firstOrNull as VideoMedia?;

  @override
  PostReelBlock copyWith({
    String? id,
    PostAuthor? author,
    DateTime? createdAt,
    List<Media>? media,
    String? caption,
    BlockAction? action,
  }) {
    return PostReelBlock(
      id: id ?? this.id,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      media: media ?? this.media,
      caption: caption ?? this.caption,
      action: action ?? this.action,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$PostReelBlockToJson(this);
}
