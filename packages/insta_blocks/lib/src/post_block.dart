import 'package:equatable/equatable.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:insta_blocks/src/block_action.dart';
import 'package:insta_blocks/src/models/models.dart';

/// {@template post_block}
/// An abstract block which represents a post block.
/// {@endtemplate}
abstract class PostBlock with EquatableMixin implements InstaBlock {
  /// {@macro post_block}
  const PostBlock({
    required this.id,
    required this.author,
    required this.publishedAt,
    required this.caption,
    required this.imageUrl,
    required this.imagesUrl,
    required this.type,
    this.action,
    this.isSponsored = false,
  });

  /// The medium post block type identifier.
  static const identifier = '__post_large__';

  /// The identifier of this post.
  final String id;

  /// The author of this post.
  @PostAuthorConverter()
  final PostAuthor author;

  /// The date when this post was published.
  final DateTime publishedAt;

  /// The image URL of this post.
  final String imageUrl;

  /// The list of images URL of this post.
  final List<String> imagesUrl;

  /// The caption of this post.
  final String caption;

  /// The bloc actions that occurs upon tapping on post author.
  @BlockActionConverter()
  final BlockAction? action;

  /// Whether the post was promoted by author.
  final bool isSponsored;

  @override
  final String type;

  @override
  List<Object?> get props => [
        id,
        author,
        publishedAt,
        imageUrl,
        caption,
        action,
        isSponsored,
        type,
      ];
}

/// The extension on [PostBlock] that provides information about actions.
extension PostBlockActions on PostBlock {
  /// Whether the action of this post is navigation.
  bool get hasNavigationAction =>
      action?.actionType == BlockActionType.navigation;
}
