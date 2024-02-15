import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comment/comment.dart';
import 'package:shared/shared.dart';

class RepliedComment extends StatelessWidget {
  const RepliedComment({
    required this.comment,
    required this.post,
    super.key,
  });

  final Comment comment;
  final PostBlock post;

  @override
  Widget build(BuildContext context) {
    return CommentView(isReplied: true, post: post, comment: comment);
  }
}
