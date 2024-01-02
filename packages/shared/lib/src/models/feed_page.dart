import 'package:equatable/equatable.dart';
import 'package:insta_blocks/insta_blocks.dart';

/// {@template feed_page}
/// Represents a page of feed data containing [Feed] blocks, the page number,
/// and whether there are more pages to load.
///
/// This is used to paginate feed requests and data.
/// {@endtemplate}
class FeedPage extends Equatable {
  /// {@macro feed_page}
  const FeedPage({
    required this.feed,
    required this.page,
    required this.hasMore,
  });

  /// {@macro feed_page.empty}
  const FeedPage.empty()
      : this(feed: const Feed.emtpy(), page: 0, hasMore: true);

  /// The current insta blocks inside the feed page.
  final Feed feed;

  /// The current page of the feed.
  final int page;

  /// Whether current page has more blocks to load.
  final bool hasMore;

  @override
  List<Object?> get props => [feed, page, hasMore];

  /// Copies the current [FeedPage] instance and overrides the provided 
  /// properties.
  FeedPage copyWith({
    Feed? feed,
    int? page,
    bool? hasMore,
  }) {
    return FeedPage(
      feed: feed ?? this.feed,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
