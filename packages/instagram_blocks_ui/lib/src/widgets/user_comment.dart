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
  AvatarTapCallback onAvatarTap,
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
    required this.onCommentDelete,
    this.onReplyButtonTap,
    this.avatarBuilder,
    super.key,
  });

  final Comment comment;
  final PostBlock post;
  final String currentUserId;
  final bool isReplied;
  final bool isLiked;
  final bool isLikedByOwner;
  final int likesCount;
  final VoidCallback onLikeComment;
  final VoidCallback onAvatarTap;
  final ValueSetter<String>? onReplyButtonTap;
  final ValueSetter<String> onCommentDelete;
  final CommentUserAvatarBuilder? avatarBuilder;

  @override
  Widget build(BuildContext context) {
    final canDeletePost =
        post.author.id == currentUserId || comment.author.id == currentUserId;
    return ListTile(
      contentPadding: EdgeInsets.only(
        right: AppSpacing.md,
        left: isReplied ? AppSpacing.xxxlg : AppSpacing.md,
      ),
      horizontalTitleGap: AppSpacing.md,
      titleAlignment: ListTileTitleAlignment.titleHeight,
      isThreeLine: true,
      onLongPress: !canDeletePost ? null : () => onCommentDelete(comment.id),
      leading: avatarBuilder?.call(
            context,
            comment.author.toUser,
            (_) => onAvatarTap.call(),
            !isReplied ? AppSize.iconSizeSmall : 16,
          ) ??
          UserProfileAvatar(
            onTap: (_) => onAvatarTap.call(),
            isLarge: false,
            radius: !isReplied ? AppSize.iconSizeSmall : AppSize.iconSizeXSmall,
            avatarUrl: comment.author.avatarUrl,
            withShimmerPlaceholder: true,
          ),
      title: Row(
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
          TimeAgo(createdAt: comment.createdAt, short: true),
          if (isLikedByOwner)
            CommentOwnerLikedAvatar(avatarUrl: post.author.avatarUrl),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: buildHighlightedText(comment, context),
          ),
          Tappable(
            onTap: () => onReplyButtonTap?.call(comment.author.username),
            animationEffect: TappableAnimationEffect.none,
            child: Text(
              BlockSettings().commentTextDelegate.replyText,
              style: context.labelMedium?.copyWith(color: AppColors.grey),
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
            onLikedTap: onLikeComment,
            size: 22,
            color: AppColors.grey,
            scaleStrength: ScaleStrength.md,
          ),
          RepaintBoundary(
            child: LikesCount(
              short: true,
              hideCount: false,
              size: 14,
              count: likesCount,
              color: AppColors.grey,
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
          color: AppColors.red,
          size: AppSize.iconSizeSmall,
        ),
        const Gap.h(AppSpacing.xs),
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
  final regexp = RegExp(r'\@[a-zA-Z0-9\-_.]+\b'); // Updated regular expression

  final mentions = <String>[];

  regexp.allMatches(text).forEach((match) {
    if (match.group(0) == null) return;
    mentions.add(match.group(0)!);
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

RichText buildHighlightedText(Comment comment, BuildContext context) {
  final commentMessage = cleanText(comment.content);

  final validMentions = <String>['@'];

  final mentions = getAllMentions(commentMessage);

  final textSpans = <TextSpan>[];
  final userIds = <String, String>{};

  commentMessage.split(' ').forEach((value) {
    if (mentions.contains(value) &&
        value.characters.contains(validMentions.first)) {
      userIds.putIfAbsent(value, () => value);
      textSpans.add(
        TextSpan(
          text: '$value ',
          style: context.bodySmall?.copyWith(
            color: AppColors.lightBlue,
            fontWeight: AppFontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              logD('$value id: ${userIds[value]}');
            },
        ),
      );
    } else {
      textSpans.add(TextSpan(text: '$value ', style: context.bodySmall));
    }
  });

  return RichText(text: TextSpan(children: textSpans));
}
