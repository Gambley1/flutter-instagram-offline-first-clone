import 'package:equatable/equatable.dart';
import 'package:insta_blocks/insta_blocks.dart';

/// {@template reels_page}
/// Represents a page of blocks data containing reels [blocks],
/// the page number, and whether there are more pages to load.
///
/// This is used to paginate blocks requests and data.
/// {@endtemplate}
class ReelsPage extends Equatable {
  /// {@macro reels_page}
  const ReelsPage({
    required this.blocks,
    required this.totalBlocks,
    required this.page,
    required this.hasMore,
  });

  /// {@macro reels_page.empty}
  const ReelsPage.empty()
      : this(blocks: const [], totalBlocks: 0, page: 0, hasMore: true);

  /// The blocks inside the blocks page.
  final List<InstaBlock> blocks;

  /// The amount of blocks in the page.
  final int totalBlocks;

  /// The current page of the blocks page.
  final int page;

  /// Whether current page has more blocks to load.
  final bool hasMore;

  @override
  List<Object?> get props => [blocks, totalBlocks, page, hasMore];

  /// Copies the current [ReelsPage] instance and overrides the provided
  /// properties.
  ReelsPage copyWith({
    List<InstaBlock>? blocks,
    int? totalBlocks,
    int? page,
    bool? hasMore,
  }) {
    return ReelsPage(
      blocks: blocks ?? this.blocks,
      totalBlocks: totalBlocks ?? this.totalBlocks,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
