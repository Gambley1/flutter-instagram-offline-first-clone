import 'package:flutter/widgets.dart';

final class BlockSettings {
  factory BlockSettings() => _internal;
  
  BlockSettings._();

  static final _internal = BlockSettings._();

  late PostTextDelegate postTextDelegate;
  late FollowTextDelegate followTextDelegate;
  late DateTimeTextDeleagte dateTimeTextDelegate;
  late CommentTextDelegate commentTextDelegate;

  void init({
    required PostTextDelegate postDelegate,
    required FollowTextDelegate followDelegate,
    required DateTimeTextDeleagte dateTimeDelegate,
    required CommentTextDelegate commentDelegate,
  }) {
    postTextDelegate = postDelegate;
    followTextDelegate = followDelegate;
    dateTimeTextDelegate = dateTimeDelegate;
    commentTextDelegate = commentDelegate;
  }
}

final class PostTextDelegate {
  const PostTextDelegate({
    required this.cancelText,
    required this.editText,
    required this.deleteText,
    required this.visitSponsoredInstagramProfileText,
    required this.noPostsText,
    required this.likedByText,
    required this.sponsoredPostText,
    required this.likesCountText,
    required this.likesCountShortText,
    required this.deletePostText,
    required this.deletePostConfirmationText,
    required this.dontShowAgainText,
    required this.blockPostAuthorText,
    required this.blockAuthorText,
    required this.blockAuthorConfirmationText,
    required this.blockText,
  });

  final String cancelText;
  final String editText;
  final String deleteText;
  final String deletePostText;
  final String deletePostConfirmationText;
  final String dontShowAgainText;
  final String blockPostAuthorText;
  final String blockAuthorText;
  final String blockAuthorConfirmationText;
  final String blockText;
  final String visitSponsoredInstagramProfileText;
  final String noPostsText;
  final TextSpan Function(int count, String name, VoidCallback? onUsernameTap)
      likedByText;
  final String sponsoredPostText;
  final String Function(int) likesCountText;
  final String Function(int) likesCountShortText;
}

final class CommentTextDelegate {
  const CommentTextDelegate({
    required this.seeAllCommentsText,
    required this.replyText,
  });

  final String Function(int) seeAllCommentsText;
  final String replyText;
}

final class FollowTextDelegate {
  const FollowTextDelegate({
    required this.followText,
    required this.followingText,
  });

  final String followText;
  final String followingText;
}

final class DateTimeTextDeleagte {
  const DateTimeTextDeleagte({
    required this.timeAgo,
    required this.timeAgoShort,
  });

  final String Function(DateTime createdAt) timeAgo;
  final String Function(DateTime createdAt) timeAgoShort;
}
