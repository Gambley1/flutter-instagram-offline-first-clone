import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get feedAppBarTitle => 'Feed';

  @override
  String get homeNavBarItemLabel => 'Home';

  @override
  String get searchNavBarItemLabel => 'Search';

  @override
  String get createMediaNavBarItemLabel => 'Create media';

  @override
  String get reelsNavBarItemLabel => 'Reels';

  @override
  String get profileNavBarItemLabel => 'Profile';

  @override
  String get likesText => 'Likes';

  @override
  String likesCountText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '$count like',
    );
    return '$_temp0';
  }

  @override
  String likedByText(String userName, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count others',
      one: '$count other',
    );
    return 'Liked by $userName and $_temp0';
  }

  @override
  String get likeText => 'Like';

  @override
  String get unlikeText => 'Unlike';

  @override
  String likesCountTextShort(int count) {
    return '$count';
  }

  @override
  String get originalAudioText => 'Original audio';

  @override
  String get discardEditsText => 'Discard Edits';

  @override
  String get discardText => 'Discard';

  @override
  String get doneText => 'Done';

  @override
  String get draftEmpty => 'Draft empty';

  @override
  String get errorText => 'Error';

  @override
  String get uploadText => 'Upload';

  @override
  String get loseAllEditsText => 'If you go back now, youll loose all the edits youve made.';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get successfullySavedText => 'Successfully saved';

  @override
  String get tapToTypeText => 'Tap to type...';

  @override
  String get noPostsText => 'No Posts Yet!';

  @override
  String get noPostFoundText => 'No post found!';

  @override
  String get addCommentText => 'Add a comment';

  @override
  String get noChatsText => 'No chats yet!';

  @override
  String get startChatText => 'Start a chat';

  @override
  String get deleteCommentText => 'Delete comment';

  @override
  String get commentDeleteConfirmationText => 'Are you sure you want to delete this comment?';

  @override
  String get deleteMessageText => 'Delete message';

  @override
  String get messageDeleteConfirmationText => 'Are you sure you want to delete this message?';

  @override
  String get deleteChatText => 'Delete chat';

  @override
  String get chatDeleteConfirmationText => 'Are you sure you want to delete this chat?';

  @override
  String get deleteReelText => 'Delete Reel';

  @override
  String get reelDeleteConfirmationText => 'Are you sure you want to delete this Reel?';

  @override
  String get deleteStoryText => 'Delete story';

  @override
  String get storyDeleteConfirmationText => 'Are you sure you want to delete this story?';

  @override
  String get commentText => 'Comment';

  @override
  String get commentsText => 'Comments';

  @override
  String get noCommentsText => 'No comments';

  @override
  String seeAllComments(int count) {
    return 'View all $count comments';
  }

  @override
  String get yourStoryLabel => 'Your story';

  @override
  String get postsText => 'Posts';

  @override
  String get followUser => 'Follow';

  @override
  String get followingUser => 'Following';

  @override
  String get followersText => 'Followers';

  @override
  String get followingsText => 'Following';

  @override
  String followersCountText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count followers',
      one: '$count follower',
    );
    return '$_temp0';
  }

  @override
  String followingsCountText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count following',
    );
    return '$_temp0';
  }

  @override
  String postsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Posts',
      one: 'Post',
    );
    return '$_temp0';
  }

  @override
  String get profilePostsAppBarTitle => 'Posts';

  @override
  String followersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Followers',
      one: 'Follower',
    );
    return '$_temp0';
  }

  @override
  String followingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Followings',
      one: 'Following',
    );
    return '$_temp0';
  }

  @override
  String get optionsText => 'Options';

  @override
  String get viewProfileText => 'View profile';

  @override
  String get editProfileText => 'Edit profile';

  @override
  String get editingText => 'Editing';

  @override
  String get editPostText => 'Edit post';

  @override
  String get shareProfileText => 'Share profile';

  @override
  String get sharePostText => 'Share';

  @override
  String get sharePostCaptionHintText => 'Add a message...';

  @override
  String get sendText => 'Send';

  @override
  String get sendSeparatelyText => 'Send separately';

  @override
  String get addStoryText => 'New';

  @override
  String get sponsoredPostText => 'Sponsored';

  @override
  String get visitSponsoredInstagramProfile => 'Visit Instagram Profile';

  @override
  String get visitSponsoredPostAuthorProfileText => 'Visit Instagram Profile';

  @override
  String get learnMoreAboutUserPromoText => 'Learn more';

  @override
  String get visitUserPromoWebsiteText => 'Go to website';

  @override
  String get cancelFollowingText => 'Unfollow';

  @override
  String get haveSeenAllRecentPosts => 'You\'re all caught up';

  @override
  String get haveSeenAllRecentPostsInPast3Days => 'You\'ve seen all new posts from the past 3 days.';

  @override
  String get suggestedForYouText => 'Suggested for you';

  @override
  String get andText => 'and';

  @override
  String othersText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count others',
      one: '$count other',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get newPostText => 'New post';

  @override
  String get newAvatarImageText => 'New avatar image';

  @override
  String get writeCaptionText => 'Write caption...';

  @override
  String get logOutText => 'Log out';

  @override
  String get logOutConfirmationText => 'Are you sure you want to log out?';

  @override
  String get notShowAgainText => 'Dont\'t show again';

  @override
  String get blockPostAuthorText => 'Block post author';

  @override
  String get blockAuthorText => 'Block author';

  @override
  String get blockAuthorConfirmationText => 'Are you sure you want to block this author?';

  @override
  String get blockText => 'Block';

  @override
  String get refreshText => 'Refresh';

  @override
  String get noReelsFoundText => 'No Reels Yet';

  @override
  String get publishText => 'Publish';

  @override
  String get searchText => 'Search';

  @override
  String get addMessageText => 'Add message';

  @override
  String get messageText => 'Message';

  @override
  String get editPictureText => 'Edit picture';

  @override
  String get requiredFieldText => 'This field is required';

  @override
  String passwordLengthErrorText(int characters, num count) {
    return 'Password should contain at least $count characters';
  }

  @override
  String get changeText => 'Change';

  @override
  String get changePhotoText => 'Change photo';

  @override
  String get fullNameEditDescription => 'Help people discover your account by using the name yor\'re known by: either your full name, nickname, or business name.\n\nYou can only change your name twice within 14 days.';

  @override
  String usernameEditDescription(String username) {
    return 'You\'ll be able to change your username back to $username for another 14 days';
  }

  @override
  String profileInfoEditConfirmationText(String newUsername, String changeType) {
    return 'Are you sure you want to change your $changeType to $newUsername ?';
  }

  @override
  String profileInfoChangePeriodText(String changeType, int count) {
    return 'You can change your $changeType only twice in $count days ';
  }

  @override
  String get forgotPasswordText => 'Forgot password?';

  @override
  String get recoveryPasswordText => 'Password recovery';

  @override
  String get orText => 'Or';

  @override
  String signInWithText(String provider) {
    return 'Sign in with $provider';
  }

  @override
  String get goBackConfirmationText => 'Are you sure you want to go back?';

  @override
  String get goBackText => 'Go back';

  @override
  String get furtherText => 'Furhter';

  @override
  String get somethingWentWrongText => 'Something went wrong!';

  @override
  String get failedToCreateStoryText => 'Failed to create story';

  @override
  String get successfullyCreatedStoryText => 'Successfully created story!';

  @override
  String get createText => 'Create';

  @override
  String get reelText => 'Reel';

  @override
  String get postText => 'Post';

  @override
  String get storyText => 'Story';

  @override
  String get removeText => 'Remove';

  @override
  String get removeFollowerText => 'Remove follower';

  @override
  String get removeFollowerConfirmationText => 'Are you sure you want to remove follower?';

  @override
  String get deletePostText => 'Delete post';

  @override
  String get deletePostConfirmationText => 'Are you sure you want to delete this post?';

  @override
  String get cancelText => 'Cancel';

  @override
  String get captionText => 'Caption';

  @override
  String get noCameraFoundText => 'No camera found!';

  @override
  String get videoText => 'VIDEO';

  @override
  String get photoText => 'PHOTO';

  @override
  String get clearImagesText => 'Clear selected images';

  @override
  String get galleryText => 'GALLERY';

  @override
  String get deletingText => 'DELETE';

  @override
  String get notFoundingCameraText => 'No secondary camera found';

  @override
  String get holdButtonText => 'Press and hold to record';

  @override
  String get noImagesFoundedText => 'There is no images';

  @override
  String get acceptAllPermissionsText => 'Failed! accept all access permissions.';

  @override
  String get noLastMessagesText => 'No last messages';

  @override
  String get onlineText => 'online';

  @override
  String get moreText => 'More';

  @override
  String get noAccountText => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccountText => 'Already have an account?';

  @override
  String get nameText => 'Name';

  @override
  String get usernameText => 'Username';

  @override
  String get forgotPasswordEmailConfirmationText => 'Email verification';

  @override
  String verificationTokenSentText(String email) {
    return 'Verification token sent to $email';
  }

  @override
  String get emailText => 'Email';

  @override
  String get otpText => 'Reset token';

  @override
  String get changePasswordText => 'Change password';

  @override
  String get passwordText => 'Password';

  @override
  String get newPasswordText => 'New password';

  @override
  String get loginText => 'Login';

  @override
  String get signUpText => 'Sign up';

  @override
  String get bioText => 'Bio';

  @override
  String get postUnavailableText => 'Post unavailable';

  @override
  String get postUnavailableDescriptionText => 'This post is unavailable';

  @override
  String get editText => 'Edit';

  @override
  String get editedText => 'edited';

  @override
  String get deleteText => 'Delete';

  @override
  String get replyText => 'Reply';

  @override
  String replyToText(Object username) {
    return 'Reply to $username';
  }

  @override
  String get themeText => 'Theme';

  @override
  String get systemOption => 'System';

  @override
  String get lightModeOption => 'Light';

  @override
  String get darkModeOption => 'Dark';

  @override
  String get languageText => 'Language';

  @override
  String get ruOptionText => 'Russian';

  @override
  String get enOptionText => 'English';

  @override
  String secondsAgo(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds ago',
      one: '1 second ago',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String weeksAgo(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String yearsAgo(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get networkError => 'A network error has occurred.\nCheck your connection and try again.';

  @override
  String get networkErrorButton => 'Try Again';
}
