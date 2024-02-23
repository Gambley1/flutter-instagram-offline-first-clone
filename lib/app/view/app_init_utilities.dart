import 'package:app_ui/app_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/time_ago.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

void initUtilities(BuildContext context, Locale locale) {
  final isSameLocal = Localizations.localeOf(context) == locale;
  if (isSameLocal) return;

  final l10n = context.l10n;
  final t = context.t;

  PickImage.instance.init(
    TabsTexts(
      photoText: l10n.photoText,
      videoText: l10n.videoText,
      acceptAllPermissions: l10n.acceptAllPermissions,
      clearImagesText: l10n.clearImagesText,
      deletingText: l10n.deletingText,
      galleryText: l10n.galleryText,
      holdButtonText: l10n.holdButtonText,
      noImagesFounded: l10n.noImagesFounded,
      notFoundingCameraText: l10n.notFoundingCameraText,
      noCameraFound: l10n.noCameraFound,
    ),
  );
  BlockSettings.instance.init(
    postDelegate: PostTextDelegate(
      editText: l10n.edit,
      deleteText: l10n.delete,
      visitSponsoredInstagramProfileText: l10n.visitSponsoredInstagramProfile,
      likedByText: (count, name, onUsernameTap) => t.likedBy(
        name: TextSpan(
          text: name,
          style: context.titleMedium?.copyWith(fontWeight: AppFontWeight.bold),
          recognizer: TapGestureRecognizer()..onTap = onUsernameTap,
        ),
        and: TextSpan(text: count < 1 ? '' : l10n.and),
        others: TextSpan(
          text: l10n.others(count),
          style: context.titleMedium?.copyWith(fontWeight: AppFontWeight.bold),
        ),
      ),
      sponsoredPostText: l10n.sponsoredPostText,
      likesCountText: l10n.likesCountText,
      likesCountShortText: l10n.likesCountTextShort,
    ),
    commentDelegate: CommentTextDelegate(
      seeAllCommentsText: l10n.seeAllComments,
      replyText: l10n.reply,
    ),
    dateTimeDelegate: DateTimeTextDeleagte(
      timeAgo: (createdAt) => createdAt.timeAgo(context),
      timeAgoShort: (createdAt) => createdAt.timeAgoShort(context),
    ),
    followDelegate: FollowTextDelegate(
      followText: l10n.followUser,
      followingText: l10n.followingUser,
    ),
  );
}
