import 'package:equatable/equatable.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:insta_blocks/src/insta_blocks_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feed_page.g.dart';

/// {@template feed_page}
/// A representation of Instagram feed page.
/// {@endtemplate}
@JsonSerializable()
class FeedPage extends Equatable {
  /// {@macro feed_page}
  const FeedPage({
    required this.blocks,
    required this.totalBlocks,
    required this.page,
    required this.hasMore,
  });

  /// {@macro feed_page.empty}
  const FeedPage.empty()
      : this(blocks: const [], totalBlocks: 0, page: 0, hasMore: true);

  /// Converts a `Map<String, dynamic>` into a [FeedPage] instance.
  factory FeedPage.fromJson(Map<String, dynamic> json) =>
      _$FeedPageFromJson(json);

  /// The current insta blocks inside the feed.
  @InstaBlocksConverter()
  final List<InstaBlock> blocks;

  /// The total number of blocks in the feed.
  final int totalBlocks;

  /// The current page of the feed.
  final int page;

  /// Whether current page has more blocks to load.
  final bool hasMore;

  /// Converts current instance into a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() => _$FeedPageToJson(this);

  @override
  List<Object> get props => [blocks, totalBlocks, page, hasMore];

  /// Copies the current [FeedPage] instance and overrides the provided
  /// properties.
  FeedPage copyWith({
    List<InstaBlock>? blocks,
    int? totalBlocks,
    int? page,
    bool? hasMore,
  }) {
    return FeedPage(
      blocks: blocks ?? this.blocks,
      totalBlocks: totalBlocks ?? this.totalBlocks,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
