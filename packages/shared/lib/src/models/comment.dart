import 'package:equatable/equatable.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:shared/shared.dart';

part 'comment.g.dart';

/// {@template comment}
/// Comment model class representing a comment on a post.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Comment extends Equatable {
  /// {@macro comment}
  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
    this.repliedToCommentId,
    this.replies,
  });

  /// Converts [Comment] instance from a `Map<String, dynamic>`
  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  /// Converts a [row] into a [Comment] instance.
  factory Comment.fromRow(Map<String, dynamic> row) => Comment(
        id: row['id'] as String,
        postId: row['post_id'] as String,
        author: PostAuthor(
          id: row['user_id'] as String,
          avatarUrl: row['avatar_url'] as String? ?? '',
          username:
              row['username'] as String? ?? row['full_name'] as String? ?? '',
        ),
        content: row['content'] as String,
        repliedToCommentId: row['replied_to_comment_id'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        replies: row['replies'] as int?,
      );

  /// The identifier of the comment.
  final String id;

  /// The identifier of the post the comment belongs to.
  final String postId;

  /// The author of the comment.
  final PostAuthor author;

  /// The identifier of the comment this comment was replied to.
  final String? repliedToCommentId;

  /// The number of replies to this comment.
  final int? replies;

  /// The content of the comment.
  final String content;

  /// Time the comment was created.
  final DateTime createdAt;

  /// Whether the comment is a reply to another comment.
  bool get isReplied => !(repliedToCommentId == null);

  @override
  List<Object?> get props => [
        id,
        postId,
        author,
        repliedToCommentId,
        content,
        createdAt,
        isReplied,
        replies,
      ];

  /// Converts current [Comment] instance to the `Map<String, dynamic>`.
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
