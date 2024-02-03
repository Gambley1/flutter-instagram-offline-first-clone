// ignore_for_file: parameter_assignments

import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/like_button.dart';
import 'package:instagram_blocks_ui/src/likes_count.dart';
import 'package:instagram_blocks_ui/src/post_large/post_header.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

typedef CommentUserAvatarBuilder = Widget Function(
  BuildContext context,
  User author,
  OnAvatarTapCallback onAvatarTap,
  double? radius,
);

class UserComment extends StatelessWidget {
  const UserComment({
    required this.comment,
    required this.post,
    required this.currentUserId,
    required this.isReplied,
    required this.onAvatarTap,
    required this.isLiked,
    required this.isLikedByOwner,
    required this.onLikeComment,
    required this.likesCount,
    required this.likesText,
    required this.createdAt,
    required this.onCommentDelete,
    required this.showDeleteCommentConfirm,
    this.onReplyButtonTap,
    this.avatarBuilder,
    super.key,
  });

  final Comment comment;
  final PostBlock post;
  final String currentUserId;
  final bool isReplied;
  final Stream<bool> isLiked;
  final Stream<bool> isLikedByOwner;
  final Stream<int> likesCount;
  final LikesText likesText;
  final LikeCallback onLikeComment;
  final VoidCallback onAvatarTap;
  final ValueSetter<String>? onReplyButtonTap;
  final ValueSetter<String> onCommentDelete;
  final Future<bool?> Function() showDeleteCommentConfirm;
  final String createdAt;
  final CommentUserAvatarBuilder? avatarBuilder;

  @override
  Widget build(BuildContext context) {
    final canDeletePost =
        post.author.id == currentUserId || comment.author.id == currentUserId;
    return ListTile(
      contentPadding: EdgeInsets.only(
        right: AppSpacing.md,
        left: isReplied ? 62 : AppSpacing.md,
      ),
      horizontalTitleGap: AppSpacing.md,
      titleAlignment: ListTileTitleAlignment.titleHeight,
      isThreeLine: true,
      onLongPress: !canDeletePost
          ? null
          : () async {
              final isConfirmed = await showDeleteCommentConfirm();
              if (isConfirmed == null || !isConfirmed) return;
              onCommentDelete(comment.id);
            },
      leading: avatarBuilder?.call(
            context,
            comment.author.toUser,
            (_) => onAvatarTap,
            !isReplied ? null : 14,
          ) ??
          UserProfileAvatar(
            isLarge: false,
            radius: !isReplied ? null : 14,
            avatarUrl: comment.author.avatarUrl,
            onTap: (_) => onAvatarTap,
            withShimmerPlaceholder: true,
          ),
      title: StreamBuilder<bool>(
        stream: isLikedByOwner,
        builder: (context, snapshot) {
          final isLiked = snapshot.data;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tappable(
                onTap: onAvatarTap,
                animationEffect: TappableAnimationEffect.none,
                child: Text(
                  '${comment.author.username} ',
                  style: context.labelLarge,
                ),
              ),
              TimeAgo(createdAt: '$createdAt '),
              if (isLiked != null && isLiked)
                CommentOwnerLikedAvatar(avatarUrl: post.author.avatarUrl),
            ],
          );
        },
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: buildHighlightedText(comment.content),
          ),
          Tappable(
            onTap: () => onReplyButtonTap?.call(comment.author.username),
            animationEffect: TappableAnimationEffect.none,
            child: Text(
              'Reply',
              style: context.labelMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          LikeButton(
            isLiked: isLiked,
            like: onLikeComment,
            size: 22,
            color: Colors.grey.shade500,
            scaleStrength: ScaleStrength.md,
          ),
          RepaintBoundary(
            child: LikesCount(
              likesCount: likesCount,
              likesText: likesText,
              size: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class CommentOwnerLikedAvatar extends StatelessWidget {
  const CommentOwnerLikedAvatar({required this.avatarUrl, super.key});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.favorite,
          color: Colors.red,
          size: AppSize.iconSizeSmall,
        ),
        const SizedBox(width: 4),
        Container(
          height: AppSize.iconSizeSmall,
          width: AppSize.iconSizeSmall,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

List<String> getAllHashtags(String text) {
  final regexp = RegExp(r'\#[a-zA-Z0-9]+\b()');

  final hashtags = <String>[];

  regexp.allMatches(text).forEach((element) {
    if (element.group(0) != null) {
      hashtags.add(element.group(0).toString());
    }
  });

  return hashtags;
}

List<String> getAllMentions(String text) {
  final regexp = RegExp(r'\@[a-zA-Z0-9]+\b()');

  final mentions = <String>[];

  regexp.allMatches(text).forEach((element) {
    if (element.group(0) != null) {
      mentions.add(element.group(0).toString());
    }
  });

  return mentions;
}

String cleanText(String text) {
  text = text.replaceAllMapped(
    RegExp(r'\w#+'),
    (m) => "${m[0]?.split('').join(" ")}",
  );

  text = text.replaceAllMapped(
    RegExp(r'\w@+'),
    (m) => "${m[0]?.split('').join(" ")}",
  );

  return text;
}

RichText buildHighlightedText(String text) {
  text = cleanText(text);

  final validMentions = <String>['@'];

  final mentions = getAllMentions(text);

  final textSpans = <TextSpan>[];
  final userIds = <String, String>{};

  text.split(' ').forEach((value) {
    if (mentions.contains(value) &&
        value.characters.contains(validMentions.first)) {
      userIds.putIfAbsent(value, () => value);
      textSpans.add(
        TextSpan(
          text: '$value ',
          style: TextStyle(
            color: Colors.blueAccent[100],
            fontWeight: FontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              logI('$value id: ${userIds[value]}');
            },
        ),
      );
    } else {
      textSpans.add(TextSpan(text: '$value '));
    }
  });

  return RichText(text: TextSpan(children: textSpans));
}
