import 'package:equatable/equatable.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:insta_blocks/src/insta_blocks_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feed.g.dart';

/// {@template feed}
/// A representation of Instagram feed.
@JsonSerializable()
class Feed extends Equatable {
  /// {@macro feed}
  const Feed({
    required this.blocks,
    required this.totalBlocks,
  });

  /// {@macro feed.empty}
  const Feed.emtpy() : this(blocks: const [], totalBlocks: 0);

  /// Converts a `Map<String, dynamic>` into a [Feed] instance.
  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);

  /// The current insta blocks inside the feed.
  @InstaBlocksConverter()
  final List<InstaBlock> blocks;

  /// The total number of blocks in the feed.
  final int totalBlocks;

  /// Converts current instance into a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() => _$FeedToJson(this);

  @override
  List<Object> get props => [blocks, totalBlocks];

  /// Copies the current [Feed] instance and overrides the provided
  /// properties.
  Feed copyWith({
    List<InstaBlock>? blocks,
    int? totalBlocks,
  }) {
    return Feed(
      blocks: blocks ?? this.blocks,
      totalBlocks: totalBlocks ?? this.totalBlocks,
    );
  }
}
