import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

/// {@template feed}
/// Represents a page of feed data containing [Feed] blocks, the page number,
/// and whether there are more pages to load.
///
/// This is used to paginate feed requests and data.
/// {@endtemplate}
class Feed extends Equatable {
  /// {@macro feed}
  const Feed({required this.feedPage, required this.reelsPage});

  /// {@macro feed.empty}
  const Feed.empty()
      : this(
          feedPage: const FeedPage.empty(),
          reelsPage: const ReelsPage.empty(),
        );

  /// The current feed page inside [Feed].
  final FeedPage feedPage;

  /// The current reels page inside [Feed].
  final ReelsPage reelsPage;

  @override
  List<Object?> get props => [feedPage];

  /// Copies the current [Feed] instance and overrides the provided
  /// properties.
  Feed copyWith({
    FeedPage? feedPage,
    ReelsPage? reelsPage,
  }) {
    return Feed(
      feedPage: feedPage ?? this.feedPage,
      reelsPage: reelsPage ?? this.reelsPage,
    );
  }
}
