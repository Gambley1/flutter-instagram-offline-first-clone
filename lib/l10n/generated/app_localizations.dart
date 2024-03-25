import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// Text shown in the Feed screen in the AppBar
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feedAppBarTitle;

  /// Home navigation bar item tooltip
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavBarItemLabel;

  /// Search navigation bar item tooltip
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchNavBarItemLabel;

  /// Create media navigation bar item tooltip
  ///
  /// In en, this message translates to:
  /// **'Create media'**
  String get createMediaNavBarItemLabel;

  /// Reels navigation bar item tooltip
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get reelsNavBarItemLabel;

  /// Profile navigation bar item tooltip
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileNavBarItemLabel;

  /// Text displaying statis Likes text
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likesText;

  /// Text shown in post footer section that display count of likes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} like} other{{count} likes}}'**
  String likesCountText(int count);

  /// No description provided for @likedByText.
  ///
  /// In en, this message translates to:
  /// **'Liked by {userName} and {count, plural, =1{{count} other} other{{count} others}}'**
  String likedByText(String userName, int count);

  /// No description provided for @likeText.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeText;

  /// No description provided for @unlikeText.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get unlikeText;

  /// Text shown in post footer section that display short count of likes
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String likesCountTextShort(int count);

  /// No description provided for @originalAudioText.
  ///
  /// In en, this message translates to:
  /// **'Original audio'**
  String get originalAudioText;

  /// No description provided for @discardEditsText.
  ///
  /// In en, this message translates to:
  /// **'Discard Edits'**
  String get discardEditsText;

  /// No description provided for @discardText.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardText;

  /// No description provided for @doneText.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneText;

  /// No description provided for @draftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Draft empty'**
  String get draftEmpty;

  /// No description provided for @errorText.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorText;

  /// No description provided for @uploadText.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadText;

  /// No description provided for @loseAllEditsText.
  ///
  /// In en, this message translates to:
  /// **'If you go back now, you\'ll loose all the edits you\'ve made.'**
  String get loseAllEditsText;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @successfullySavedText.
  ///
  /// In en, this message translates to:
  /// **'Successfully saved'**
  String get successfullySavedText;

  /// No description provided for @tapToTypeText.
  ///
  /// In en, this message translates to:
  /// **'Tap to type...'**
  String get tapToTypeText;

  /// No description provided for @noPostsText.
  ///
  /// In en, this message translates to:
  /// **'No Posts Yet!'**
  String get noPostsText;

  /// No description provided for @noPostFoundText.
  ///
  /// In en, this message translates to:
  /// **'No post found!'**
  String get noPostFoundText;

  /// No description provided for @addCommentText.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get addCommentText;

  /// No description provided for @noChatsText.
  ///
  /// In en, this message translates to:
  /// **'No chats yet!'**
  String get noChatsText;

  /// No description provided for @startChatText.
  ///
  /// In en, this message translates to:
  /// **'Start a chat'**
  String get startChatText;

  /// No description provided for @deleteCommentText.
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get deleteCommentText;

  /// No description provided for @commentDeleteConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get commentDeleteConfirmationText;

  /// No description provided for @deleteMessageText.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get deleteMessageText;

  /// No description provided for @messageDeleteConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get messageDeleteConfirmationText;

  /// No description provided for @deleteChatText.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get deleteChatText;

  /// No description provided for @chatDeleteConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat?'**
  String get chatDeleteConfirmationText;

  /// No description provided for @deleteReelText.
  ///
  /// In en, this message translates to:
  /// **'Delete Reel'**
  String get deleteReelText;

  /// No description provided for @reelDeleteConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Reel?'**
  String get reelDeleteConfirmationText;

  /// No description provided for @deleteStoryText.
  ///
  /// In en, this message translates to:
  /// **'Delete story'**
  String get deleteStoryText;

  /// No description provided for @storyDeleteConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this story?'**
  String get storyDeleteConfirmationText;

  /// No description provided for @commentText.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentText;

  /// No description provided for @commentsText.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsText;

  /// No description provided for @noCommentsText.
  ///
  /// In en, this message translates to:
  /// **'No comments'**
  String get noCommentsText;

  /// Text shown under the post caption
  ///
  /// In en, this message translates to:
  /// **'View all {count} comments'**
  String seeAllComments(int count);

  /// Text shown under the first storie in stories list view marked as your story
  ///
  /// In en, this message translates to:
  /// **'Your story'**
  String get yourStoryLabel;

  /// Text displaying static Posts text
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postsText;

  /// No description provided for @followUser.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followUser;

  /// No description provided for @followingUser.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingUser;

  /// Text displaying static Followers text
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followersText;

  /// Text displaying static Following text
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingsText;

  /// No description provided for @followersCountText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} follower} other{{count} followers}}'**
  String followersCountText(int count);

  /// No description provided for @followingsCountText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} following}}'**
  String followingsCountText(int count);

  /// Text describing the count of posts
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Post} other{Posts}}'**
  String postsCount(int count);

  /// Text shown in app bar in user's all posts screen
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get profilePostsAppBarTitle;

  /// Text describing the count of posts
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Follower} other{Followers}}'**
  String followersCount(int count);

  /// Text describing the count of user followings
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Following} other{Followings}}'**
  String followingsCount(int count);

  /// No description provided for @optionsText.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsText;

  /// No description provided for @viewProfileText.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfileText;

  /// Text shown in account view to edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileText;

  /// No description provided for @editingText.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get editingText;

  /// Text shown in post edit view to edit post
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get editPostText;

  /// Text shown in account view to share profile
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get shareProfileText;

  /// Tooltip text shown in post popup to share post
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get sharePostText;

  /// No description provided for @sharePostCaptionHintText.
  ///
  /// In en, this message translates to:
  /// **'Add a message...'**
  String get sharePostCaptionHintText;

  /// No description provided for @sendText.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendText;

  /// No description provided for @sendSeparatelyText.
  ///
  /// In en, this message translates to:
  /// **'Send separately'**
  String get sendSeparatelyText;

  /// Text shown in account view to add new story
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get addStoryText;

  /// Text shown on sponsored post indicating that the post is sponsored by author
  ///
  /// In en, this message translates to:
  /// **'Sponsored'**
  String get sponsoredPostText;

  /// Text shown on sponsored post telling that this action will navigate user to author's instagram profile
  ///
  /// In en, this message translates to:
  /// **'Visit Instagram Profile'**
  String get visitSponsoredInstagramProfile;

  /// Text shown on sponsored post telling that this action will navigate user to author profile
  ///
  /// In en, this message translates to:
  /// **'Visit Instagram Profile'**
  String get visitSponsoredPostAuthorProfileText;

  /// Text shown in a floating action promo in user profile when was navigated from sponsored post
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMoreAboutUserPromoText;

  /// Text shown in a floating action promo in user profile when was navigated from sponsored post
  ///
  /// In en, this message translates to:
  /// **'Go to website'**
  String get visitUserPromoWebsiteText;

  /// Text shown in modal bottom sheet to cancel current following to user
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get cancelFollowingText;

  /// Header text shown in divider block when user have seen all recent posts
  ///
  /// In en, this message translates to:
  /// **'You\'\'re all caught up'**
  String get haveSeenAllRecentPosts;

  /// Body text shown in divider block when user have seen all recent posts in past 3 days
  ///
  /// In en, this message translates to:
  /// **'You\'\'ve seen all new posts from the past 3 days.'**
  String get haveSeenAllRecentPostsInPast3Days;

  /// Text shown in a suggested section block.
  ///
  /// In en, this message translates to:
  /// **'Suggested for you'**
  String get suggestedForYouText;

  /// No description provided for @andText.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andText;

  /// No description provided for @othersText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{} =1{{count} other} other{{count} others}}'**
  String othersText(int count);

  /// No description provided for @newPostText.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get newPostText;

  /// No description provided for @newAvatarImageText.
  ///
  /// In en, this message translates to:
  /// **'New avatar image'**
  String get newAvatarImageText;

  /// No description provided for @writeCaptionText.
  ///
  /// In en, this message translates to:
  /// **'Write caption...'**
  String get writeCaptionText;

  /// No description provided for @logOutText.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutText;

  /// No description provided for @logOutConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirmationText;

  /// No description provided for @notShowAgainText.
  ///
  /// In en, this message translates to:
  /// **'Dont\'\'t show again'**
  String get notShowAgainText;

  /// No description provided for @blockPostAuthorText.
  ///
  /// In en, this message translates to:
  /// **'Block post author'**
  String get blockPostAuthorText;

  /// No description provided for @blockAuthorText.
  ///
  /// In en, this message translates to:
  /// **'Block author'**
  String get blockAuthorText;

  /// No description provided for @blockAuthorConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this author?'**
  String get blockAuthorConfirmationText;

  /// No description provided for @blockText.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockText;

  /// No description provided for @refreshText.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshText;

  /// No description provided for @noReelsFoundText.
  ///
  /// In en, this message translates to:
  /// **'No Reels Yet'**
  String get noReelsFoundText;

  /// No description provided for @publishText.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishText;

  /// No description provided for @searchText.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchText;

  /// No description provided for @addMessageText.
  ///
  /// In en, this message translates to:
  /// **'Add message'**
  String get addMessageText;

  /// No description provided for @messageText.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageText;

  /// No description provided for @editPictureText.
  ///
  /// In en, this message translates to:
  /// **'Edit picture'**
  String get editPictureText;

  /// No description provided for @requiredFieldText.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredFieldText;

  /// No description provided for @passwordLengthErrorText.
  ///
  /// In en, this message translates to:
  /// **'Password should contain at least {count} characters'**
  String passwordLengthErrorText(int characters, num count);

  /// No description provided for @changeText.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeText;

  /// No description provided for @changePhotoText.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhotoText;

  /// No description provided for @fullNameEditDescription.
  ///
  /// In en, this message translates to:
  /// **'Help people discover your account by using the name yor\'\'re known by: either your full name, nickname, or business name.\n\nYou can only change your name twice within 14 days.'**
  String get fullNameEditDescription;

  /// No description provided for @usernameEditDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ll be able to change your username back to {username} for another 14 days'**
  String usernameEditDescription(String username);

  /// No description provided for @profileInfoEditConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change your {changeType} to {newUsername} ?'**
  String profileInfoEditConfirmationText(String newUsername, String changeType);

  /// No description provided for @profileInfoChangePeriodText.
  ///
  /// In en, this message translates to:
  /// **'You can change your {changeType} only twice in {count} days '**
  String profileInfoChangePeriodText(String changeType, int count);

  /// No description provided for @forgotPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordText;

  /// No description provided for @recoveryPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get recoveryPasswordText;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get orText;

  /// No description provided for @signInWithText.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {provider}'**
  String signInWithText(String provider);

  /// No description provided for @goBackConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go back?'**
  String get goBackConfirmationText;

  /// No description provided for @goBackText.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBackText;

  /// No description provided for @furtherText.
  ///
  /// In en, this message translates to:
  /// **'Furhter'**
  String get furtherText;

  /// No description provided for @somethingWentWrongText.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get somethingWentWrongText;

  /// No description provided for @failedToCreateStoryText.
  ///
  /// In en, this message translates to:
  /// **'Failed to create story'**
  String get failedToCreateStoryText;

  /// No description provided for @successfullyCreatedStoryText.
  ///
  /// In en, this message translates to:
  /// **'Successfully created story!'**
  String get successfullyCreatedStoryText;

  /// No description provided for @createText.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createText;

  /// No description provided for @reelText.
  ///
  /// In en, this message translates to:
  /// **'Reel'**
  String get reelText;

  /// No description provided for @postText.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postText;

  /// No description provided for @storyText.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get storyText;

  /// No description provided for @removeText.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeText;

  /// No description provided for @removeFollowerText.
  ///
  /// In en, this message translates to:
  /// **'Remove follower'**
  String get removeFollowerText;

  /// No description provided for @removeFollowerConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove follower?'**
  String get removeFollowerConfirmationText;

  /// No description provided for @deletePostText.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get deletePostText;

  /// No description provided for @deletePostConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get deletePostConfirmationText;

  /// No description provided for @cancelText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelText;

  /// No description provided for @captionText.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get captionText;

  /// No description provided for @noCameraFoundText.
  ///
  /// In en, this message translates to:
  /// **'No camera found!'**
  String get noCameraFoundText;

  /// No description provided for @videoText.
  ///
  /// In en, this message translates to:
  /// **'VIDEO'**
  String get videoText;

  /// No description provided for @photoText.
  ///
  /// In en, this message translates to:
  /// **'PHOTO'**
  String get photoText;

  /// No description provided for @clearImagesText.
  ///
  /// In en, this message translates to:
  /// **'Clear selected images'**
  String get clearImagesText;

  /// No description provided for @galleryText.
  ///
  /// In en, this message translates to:
  /// **'GALLERY'**
  String get galleryText;

  /// No description provided for @deletingText.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deletingText;

  /// No description provided for @notFoundingCameraText.
  ///
  /// In en, this message translates to:
  /// **'No secondary camera found'**
  String get notFoundingCameraText;

  /// No description provided for @holdButtonText.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to record'**
  String get holdButtonText;

  /// No description provided for @noImagesFoundedText.
  ///
  /// In en, this message translates to:
  /// **'There is no images'**
  String get noImagesFoundedText;

  /// No description provided for @acceptAllPermissionsText.
  ///
  /// In en, this message translates to:
  /// **'Failed! accept all access permissions.'**
  String get acceptAllPermissionsText;

  /// No description provided for @noLastMessagesText.
  ///
  /// In en, this message translates to:
  /// **'No last messages'**
  String get noLastMessagesText;

  /// No description provided for @onlineText.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get onlineText;

  /// No description provided for @moreText.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreText;

  /// No description provided for @noAccountText.
  ///
  /// In en, this message translates to:
  /// **'Don\'\'t have an account?'**
  String get noAccountText;

  /// No description provided for @alreadyHaveAccountText.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountText;

  /// No description provided for @nameText.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameText;

  /// No description provided for @usernameText.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameText;

  /// No description provided for @forgotPasswordEmailConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get forgotPasswordEmailConfirmationText;

  /// No description provided for @verificationTokenSentText.
  ///
  /// In en, this message translates to:
  /// **'Verification token sent to {email}'**
  String verificationTokenSentText(String email);

  /// No description provided for @emailText.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailText;

  /// No description provided for @otpText.
  ///
  /// In en, this message translates to:
  /// **'Reset token'**
  String get otpText;

  /// No description provided for @changePasswordText.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordText;

  /// No description provided for @passwordText.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordText;

  /// No description provided for @newPasswordText.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordText;

  /// No description provided for @loginText.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginText;

  /// No description provided for @signUpText.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpText;

  /// No description provided for @bioText.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioText;

  /// No description provided for @postUnavailableText.
  ///
  /// In en, this message translates to:
  /// **'Post unavailable'**
  String get postUnavailableText;

  /// No description provided for @postUnavailableDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'This post is unavailable'**
  String get postUnavailableDescriptionText;

  /// No description provided for @editText.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editText;

  /// No description provided for @editedText.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get editedText;

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteText;

  /// No description provided for @replyText.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get replyText;

  /// No description provided for @replyToText.
  ///
  /// In en, this message translates to:
  /// **'Reply to {username}'**
  String replyToText(Object username);

  /// No description provided for @themeText.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeText;

  /// The option to use system-wide theme in the theme selector menu
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemOption;

  /// The option for light mode in the theme selector menu
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightModeOption;

  /// The option for dark mode in the theme selector menu
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkModeOption;

  /// No description provided for @languageText.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageText;

  /// No description provided for @ruOptionText.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get ruOptionText;

  /// No description provided for @enOptionText.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get enOptionText;

  /// Represents a text of seconds ago
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =1{1 second ago} other{{seconds} seconds ago}}'**
  String secondsAgo(int seconds);

  /// Represents a text of minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute ago} other{{minutes} minutes ago}}'**
  String minutesAgo(int minutes);

  /// Represents a text of hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour ago} other{{hours} hours ago}}'**
  String hoursAgo(int hours);

  /// Represents a text of days ago
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day ago} other{{days} days ago}}'**
  String daysAgo(int days);

  /// Represents a text of weeks ago
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{1 week ago} other{{weeks} weeks ago}}'**
  String weeksAgo(int weeks);

  /// Represents a text of months ago
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =1{1 month ago} other{{months} months ago}}'**
  String monthsAgo(int months);

  /// Represents a text of years ago
  ///
  /// In en, this message translates to:
  /// **'{years, plural, =1{1 year ago} other{{years} years ago}}'**
  String yearsAgo(int years);

  /// Text displayed when a network error occurs.
  ///
  /// In en, this message translates to:
  /// **'A network error has occurred.\nCheck your connection and try again.'**
  String get networkError;

  /// Text displayed on the refresh button when a network error occurs.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get networkErrorButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
