import 'package:shared/shared.dart';

/// {@template posts_page}
/// The representation of paginated posts page with list of posts.
/// {@endtemplate}
class PostsPage {
  /// {@macro posts_page}
  PostsPage({
    required this.posts,
    required this.startIndex,
    required this.hasNext,
  });

  /// The list of posts in the page.
  final List<Post> posts;

  /// The starting index of the page.
  final String startIndex;

  /// Whether the page has the next one.
  final bool hasNext;
}
