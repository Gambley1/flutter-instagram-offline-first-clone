import 'package:flutter/widgets.dart';

final class BlockSettings {
  BlockSettings._();

  static BlockSettings get instance => _internal;

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
    required this.editText,
    required this.deleteText,
    required this.visitSponsoredInstagramProfileText,
    required this.likedByText,
    required this.sponsoredPostText,
    required this.likesCountText,
    required this.likesCountShortText,
  });

  final String editText;
  final String deleteText;
  final String visitSponsoredInstagramProfileText;
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
