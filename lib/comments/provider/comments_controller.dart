import 'package:flutter/material.dart';

class CommentsProvider {
  final isCommentReplyingTo = ValueNotifier<bool>(false);
  final _commentReplyingToUsername = ValueNotifier<String?>(null);
  final _commentReplyingToCommentId = ValueNotifier<String?>(null);
  late TextEditingController commentTextController;
  final commentFocusNode = FocusNode();

  bool get isReplying => isCommentReplyingTo.value;
  set isReplying(bool value) => isCommentReplyingTo.value = value;

  String? get commentReplyingToUsername => _commentReplyingToUsername.value;
  set commentReplyingToUsername(String? value) =>
      _commentReplyingToUsername.value = value;

  String? get commentReplyingToCommentId => _commentReplyingToCommentId.value;
  set commentReplyingToCommentId(String? value) =>
      _commentReplyingToCommentId.value = value;

  void setReplyingTo({required String commentId, required String username}) {
    clearReplying();
    final commentText = '@$username ';
    final newSelectionPosition = TextPosition(offset: commentText.length);
    commentTextController
      ..text = commentText
      ..selection = TextSelection.fromPosition(newSelectionPosition);

    commentFocusNode.requestFocus();

    isReplying = true;
    commentReplyingToUsername = username;
    commentReplyingToCommentId = commentId;
  }

  void clearReplying() {
    isReplying = false;
    commentReplyingToUsername = null;
    commentReplyingToCommentId = null;
    commentTextController.clear();
    commentFocusNode.unfocus();
  }

  void dispose() {
    isCommentReplyingTo.dispose();
    commentTextController.dispose();
    commentFocusNode.dispose();
  }
}
