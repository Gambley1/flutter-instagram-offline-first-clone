import 'package:flutter/material.dart';

class CommentInputController extends ChangeNotifier {
  bool _isReplying = false;
  String? _replyingUsername;
  String? _replyingCommentId;
  late FocusNode _commentFocusNode;
  late TextEditingController _commentTextController;

  void init({
    required FocusNode commentFocusNode,
    required TextEditingController commentTextController,
  }) {
    _commentFocusNode = commentFocusNode;
    _commentTextController = commentTextController;
  }

  set isReplying(bool value) {
    _isReplying = value;
    notifyListeners();
  }

  bool get isReplying => _isReplying;

  set replyingUsername(String? value) {
    _replyingUsername = value;
    notifyListeners();
  }

  String? get replyingUsername => _replyingUsername;

  set replyingCommentId(String? value) {
    _replyingCommentId = value;
    notifyListeners();
  }

  String? get replyingCommentId => _replyingCommentId;

  FocusNode get commentFocusNode => _commentFocusNode;
  TextEditingController get commentTextController => _commentTextController;

  void setReplyingTo({required String commentId, required String username}) {
    clear();
    final commentText = '@$username ';
    final newSelectionPosition = TextPosition(offset: commentText.length);
    _commentTextController
      ..text = commentText
      ..selection = TextSelection.fromPosition(newSelectionPosition);

    _commentFocusNode.requestFocus();

    isReplying = true;
    replyingUsername = username;
    replyingCommentId = commentId;
  }

  void onEmojiTap(String emoji) {
    _commentTextController
      ..text = _commentTextController.text + emoji
      ..selection = TextSelection.fromPosition(
        TextPosition(
          offset: _commentTextController.text.length,
        ),
      );
  }

  void clear() {
    if (isReplying) {
      isReplying = false;
      replyingUsername = null;
      replyingCommentId = null;
    }
    _commentTextController.clear();
    _commentFocusNode.unfocus();
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }
}

class CommentInheritedWidget extends InheritedWidget {
  const CommentInheritedWidget({
    required super.child,
    required this.commentInputController,
    super.key,
  });

  final CommentInputController commentInputController;

  static CommentInheritedWidget of(BuildContext context) {
    final provider =
        context.getInheritedWidgetOfExactType<CommentInheritedWidget>();
    assert(provider != null, 'No CommentInheritedWidget found in context!');
    return provider!;
  }

  @override
  bool updateShouldNotify(CommentInheritedWidget oldWidget) =>
      oldWidget.commentInputController != commentInputController;
}
