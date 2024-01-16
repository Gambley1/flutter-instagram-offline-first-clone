// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:meta/meta.dart';

/// {@template comment}
/// Comment model class representing a comment on a post.
/// {@endtemplate}
@immutable
class Comment extends Equatable {
  /// {@macro comment}
  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.isReplied,
    this.repliedToCommentId,
    this.replies,
  });

  /// Converts a [row] into a [Comment] instance.
  factory Comment.fromRow(Map<String, dynamic> row) => Comment(
        id: row['id'] as String,
        postId: row['post_id'] as String,
        author: PostAuthor(
          id: row['user_id'] as String,
          avatarUrl: row['avatar_url'] as String,
          username: row['username'] as String,
        ),
        content: row['content'] as String,
        repliedToCommentId: row['replied_to_comment_id'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        isReplied: !(row['replied_to_comment_id'] == null),
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
  final bool isReplied;

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'postId': postId,
      'author': author.id,
      'repliedToCommentId': repliedToCommentId,
      'replies': replies,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isReplied': isReplied,
    };
  }

  String toJson() => json.encode(toMap());
}
