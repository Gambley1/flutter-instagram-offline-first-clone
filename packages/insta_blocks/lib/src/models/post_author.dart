import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'post_author.g.dart';

/// {@template post_author}
/// The representation of post author.
/// {@endtemplate}
@immutable
@JsonSerializable()
class PostAuthor {
  /// {@macro post_author}
  const PostAuthor({
    required this.id,
    required this.avatarUrl,
    required this.username,
    this.isConfirmed = false,
  });

  /// {@macro post_author_confirmed}
  const PostAuthor.confirmed({
    String? id,
    String? avatarUrl,
    String? username,
  }) : this(
          avatarUrl: avatarUrl ??
              'https://wefeasvyrksvvywqgchk.supabase.co/storage/v1/object/public/avatars/126a526e-0ada-4144-90aa-30a4d3185844/avatar?t=1699129094691',
          id: id ?? '67c36f68-3b92-4e11-89e9-cd7a22f3c37b',
          username: username ?? 'emil.zulufov',
          isConfirmed: true,
        );

  /// Deserialize [json] into a [PostAuthor] instance.
  factory PostAuthor.fromJson(Map<String, dynamic> json) =>
      _$PostAuthorFromJson(json);

  /// Deserialize [shared] into a [PostAuthor] instance.
  factory PostAuthor.fromShared(Map<String, dynamic> shared) => PostAuthor(
        id: shared['shared_post_author_id'] as String,
        avatarUrl: shared['shared_post_author_avatar_url'] as String,
        username: shared['shared_post_author_username'] as String,
      );

  /// The empty instance of the [PostAuthor].
  static const PostAuthor empty =
      PostAuthor(id: '', avatarUrl: '', username: '');

  /// The identifier of the author.
  final String id;

  /// The author username.
  final String username;

  /// The author avatar url.
  final String avatarUrl;

  /// Whether the user is confirmed by the Instagram clone staff.
  final bool isConfirmed;

  /// Convert current instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() => _$PostAuthorToJson(this);
}
