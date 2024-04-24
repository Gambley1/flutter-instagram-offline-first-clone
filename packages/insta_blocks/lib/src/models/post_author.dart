import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:user_repository/user_repository.dart';

part 'post_author.g.dart';

const _confirmedUsers = <User>[
  User(
    id: '462738c5-5369-4590-818d-ac883ffa4424',
    avatarUrl:
        'https://img.freepik.com/premium-photo/cartoon-character-with-blue-shirt-glasses_561641-2084.jpg?size=626&ext=jpg',
    email: 'emilzulufov@gmail.com',
    username: 'emil.zulufov',
    fullName: 'Emil Zulufov',
  ),
  User(
    id: 'a0ee0d08-cb0e-4ba6-9401-b47a2a66cdc1',
    avatarUrl:
        'https://img.freepik.com/free-photo/3d-rendering-zoom-call-avatar_23-2149556778.jpg?size=626&ext=jpg',
    email: 'emilzulufov.commercial@gmail.com',
    username: 'emo.official',
    fullName: 'Emo Official',
  ),
];

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

  /// {@macro post_author.confirmed}
  const PostAuthor.confirmed({
    required String id,
    String? avatarUrl,
    String? username,
  }) : this(
          id: id,
          avatarUrl: avatarUrl ?? '',
          username: username ?? '',
          isConfirmed: true,
        );

  /// {@macro post_author.random_confirmed}
  factory PostAuthor.randomConfirmed({
    String? id,
    String? avatarUrl,
    String? username,
  }) {
    final randomConfirmedUser =
        _confirmedUsers[Random().nextInt(_confirmedUsers.length)];
    return PostAuthor(
      id: id ?? randomConfirmedUser.id,
      username: username ?? randomConfirmedUser.username!,
      avatarUrl: avatarUrl ?? randomConfirmedUser.avatarUrl!,
      isConfirmed: true,
    );
  }

  /// Deserialize [json] into a [PostAuthor] instance.
  factory PostAuthor.fromJson(Map<String, dynamic> json) =>
      _$PostAuthorFromJson(json);

  /// Deserialize [shared] into a [PostAuthor] instance.
  factory PostAuthor.fromShared(Map<String, dynamic> shared) => PostAuthor(
        id: shared['shared_post_author_id'] as String? ?? '',
        avatarUrl: shared['shared_post_author_avatar_url'] as String? ?? '',
        username: shared['shared_post_author_username'] as String? ??
            shared['shared_post_author_full_name'] as String? ?? '',
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
