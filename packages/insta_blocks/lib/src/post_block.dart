import 'package:equatable/equatable.dart';
import 'package:insta_blocks/src/block_action.dart';
import 'package:insta_blocks/src/models/models.dart';
import 'package:shared/shared.dart';

/// {@template post_block}
/// An abstract block which represents a post block.
/// {@endtemplate}
abstract class PostBlock extends InstaBlock with EquatableMixin {
  /// {@macro post_block}
  const PostBlock({
    required this.id,
    required this.author,
    required this.createdAt,
    required this.caption,
    required this.media,
    required super.type,
    this.action,
    this.isSponsored = false,
  });

  /// The author of this post.
  @PostAuthorConverter()
  final PostAuthor author;

  /// The unique identifier of the [PostBlock].
  final String id;

  /// The date when this post was published.
  final DateTime createdAt;

  /// The list of images URL of this post.
  @ListMediaConverterFromRemoteConfig()
  final List<Media> media;

  /// The caption of this post.
  final String caption;

  /// The bloc actions that occurs upon tapping on post author.
  @BlockActionConverter()
  final BlockAction? action;

  /// Whether the post was promoted by author.
  final bool isSponsored;

  /// The first media of the [PostBlock].
  ///
  /// ### Note
  /// Never use [firstMedia] directly to get it's url, because [firstMedia]
  /// getter returns the abstraction of [Media] and it is uncertain which
  /// type is the first media. In that case getting url from [Media] can be
  /// wrong, as the url of the [VideoMedia] is used to display the video
  /// itself.
  ///
  /// Instead use [firstMediaUrl] if you need to get a correct url to display
  /// as a preview(image).
  Media? get firstMedia => media.isEmpty ? null : media.first;

  /// The first media url of the [PostBlock].
  ///
  /// If the [firstMedia] is null returns null.
  /// If the [firstMedia] is a [VideoMedia] returns it's `firstFrameUrl`.
  /// Otherwise returns the [firstMedia] url from [ImageMedia].
  String? get firstMediaUrl => firstMedia is VideoMedia
      ? (firstMedia as VideoMedia?)?.firstFrameUrl
      : firstMedia?.url;

  /// The list of all media url of the [PostBlock].
  List<String> get mediaUrls => media.map((e) => e.url).toList();

  /// Whether the post counts as Instagram `Reel`.
  bool get isReel => media.length == 1 && firstMedia is VideoMedia;

  /// Whether the post contains at least one of both `Image` and `Video` media
  /// types.
  bool get hasBothMediaTypes =>
      media.any((media) => media is ImageMedia) &&
      media.any((media) => media is VideoMedia);

  /// Copies current [PostBlock] instance and merges with new values.
  PostBlock copyWith();

  /// Merges current [PostBlock] instance with [other] instance.
  PostBlock merge({PostBlock? other});

  @override
  List<Object?> get props => [
        id,
        author,
        createdAt,
        media,
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

/// THe extension on `List<PostLargeBlock>`.
extension PostListExtension on List<PostLargeBlock> {
  /// Provides each element in list of [PostLargeBlock] with action
  /// [NavigateToPostAuthorProfileAction].
  List<PostLargeBlock> get withNavigateToPostAuthorAction => map(
        (e) => e.copyWith(
          action: NavigateToPostAuthorProfileAction(authorId: e.author.id),
        ),
      ).toList();
}
