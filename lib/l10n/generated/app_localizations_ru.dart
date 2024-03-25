import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get feedAppBarTitle => 'Просмотр ленты';

  @override
  String get homeNavBarItemLabel => 'Лента';

  @override
  String get searchNavBarItemLabel => 'Поиск';

  @override
  String get createMediaNavBarItemLabel => 'Создать медиа';

  @override
  String get reelsNavBarItemLabel => 'Рилс';

  @override
  String get profileNavBarItemLabel => 'Профиль';

  @override
  String get likesText => 'Нравится';

  @override
  String likesCountText(int count) {
    return 'Нравится: $count';
  }

  @override
  String likedByText(String userName, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'и $count другим',
      one: '',
    );
    return 'Нравится $userName $_temp0';
  }

  @override
  String get likeText => 'Нравится';

  @override
  String get unlikeText => 'Не нравится';

  @override
  String likesCountTextShort(int count) {
    return '$count';
  }

  @override
  String get originalAudioText => 'Оригинальное аудио';

  @override
  String get discardEditsText => 'Сбросить Изменения';

  @override
  String get discardText => 'Сбросить';

  @override
  String get doneText => 'Готово';

  @override
  String get draftEmpty => 'Черновик пустой';

  @override
  String get errorText => 'Ошибка';

  @override
  String get uploadText => 'Загрузить';

  @override
  String get loseAllEditsText =>
      'Если вы вернетесь сейчас, вы потеряете все внесенные вами изменения.';

  @override
  String get saveDraft => 'Сохранить черновик';

  @override
  String get successfullySavedText => 'Успешно сохранено';

  @override
  String get tapToTypeText => 'Нажмите, чтобы печатать...';

  @override
  String get noPostsText => 'Публикаций пока нет';

  @override
  String get noPostFoundText => 'Публикация не найдена!';

  @override
  String get addCommentText => 'Добавить комментарий';

  @override
  String get noChatsText => 'Нет чатов!';

  @override
  String get startChatText => 'Создать чат';

  @override
  String get deleteCommentText => 'Удалить комментарий';

  @override
  String get commentDeleteConfirmationText =>
      'Вы уверены что хотите удалить этот комментарий?';

  @override
  String get deleteMessageText => 'Удалить сообщение';

  @override
  String get messageDeleteConfirmationText =>
      'Вы уверены что хотите удалить это сообщение?';

  @override
  String get deleteChatText => 'Удалить чат';

  @override
  String get chatDeleteConfirmationText =>
      'Вы уверены что хотите удалить этот чат?';

  @override
  String get deleteReelText => 'Удалить видео Reels';

  @override
  String get reelDeleteConfirmationText =>
      'Вы уверены что хотите удалить это видео Reels?';

  @override
  String get deleteStoryText => 'Удалить историю';

  @override
  String get storyDeleteConfirmationText =>
      'Вы уверены что хотите удалить эту историю?';

  @override
  String get commentText => 'Комментарий';

  @override
  String get commentsText => 'Комментарии';

  @override
  String get noCommentsText => 'Нет комментариев';

  @override
  String seeAllComments(int count) {
    return 'Смотреть все коментарии ($count)';
  }

  @override
  String get yourStoryLabel => 'Твоя история';

  @override
  String get postsText => 'Публикаций';

  @override
  String get followUser => 'Подписаться';

  @override
  String get followingUser => 'Вы подписаны';

  @override
  String get followersText => 'Подписчики';

  @override
  String get followingsText => 'Подписки';

  @override
  String followersCountText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Подписчики: $count',
    );
    return '$_temp0';
  }

  @override
  String followingsCountText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Подписки: $count',
    );
    return '$_temp0';
  }

  @override
  String postsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Публикаций',
      few: 'Публикации',
      one: 'Публикация',
    );
    return '$_temp0';
  }

  @override
  String get profilePostsAppBarTitle => 'Публикации';

  @override
  String followersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Подписчиков',
      few: 'Подписчика',
      one: 'Подписчик',
    );
    return '$_temp0';
  }

  @override
  String followingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Подписок',
      few: 'Подписки',
      one: 'Подписка',
    );
    return '$_temp0';
  }

  @override
  String get optionsText => 'Настройки';

  @override
  String get viewProfileText => 'Посмотреть профиль';

  @override
  String get editProfileText => 'Редактировать профиль';

  @override
  String get editingText => 'Редактирование';

  @override
  String get editPostText => 'Редактировать публикацию';

  @override
  String get shareProfileText => 'Поделиться профилем';

  @override
  String get sharePostText => 'Поделиться';

  @override
  String get sharePostCaptionHintText => 'Добавить сообщение...';

  @override
  String get sendText => 'Отправить';

  @override
  String get sendSeparatelyText => 'Отправить отдельно';

  @override
  String get addStoryText => 'Добавить';

  @override
  String get sponsoredPostText => 'Реклама';

  @override
  String get visitSponsoredInstagramProfile => 'Посетить профиль Instagram';

  @override
  String get visitSponsoredPostAuthorProfileText => 'Открыть профиль Instagram';

  @override
  String get learnMoreAboutUserPromoText => 'Узнать больше';

  @override
  String get visitUserPromoWebsiteText => 'Посетить сайт';

  @override
  String get cancelFollowingText => 'Отменить подписку';

  @override
  String get haveSeenAllRecentPosts => 'Вы посмотрели все обновления';

  @override
  String get haveSeenAllRecentPostsInPast3Days =>
      'Вы посмотрели все новые публикации за последние 3 дн.';

  @override
  String get suggestedForYouText => 'Рекомендуемые публикации';

  @override
  String get andText => 'и';

  @override
  String othersText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ещё $count',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get newPostText => 'Новая публикация';

  @override
  String get newAvatarImageText => 'Новое фото аватара';

  @override
  String get writeCaptionText => 'Добавить подпись...';

  @override
  String get logOutText => 'Выйти';

  @override
  String get logOutConfirmationText =>
      'Вы уверены что хотите выйти из аккаунта?';

  @override
  String get notShowAgainText => 'Не показывать снова';

  @override
  String get blockPostAuthorText => 'Заблокировать автора публикации';

  @override
  String get blockAuthorText => 'Заблокировать автора';

  @override
  String get blockAuthorConfirmationText =>
      'Вы уверены что хотите заблокировать этого автора?';

  @override
  String get blockText => 'Заблокировать';

  @override
  String get refreshText => 'Обновить';

  @override
  String get noReelsFoundText => 'Видео Reels пока нет';

  @override
  String get publishText => 'Отправить';

  @override
  String get searchText => 'Поиск';

  @override
  String get addMessageText => 'Сообщение';

  @override
  String get messageText => 'Сообщение';

  @override
  String get editPictureText => 'Изменить фото';

  @override
  String get requiredFieldText => 'Это поле обязательно';

  @override
  String passwordLengthErrorText(int characters, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count символа',
      one: '$count символ',
    );
    return 'Пароль должен содержать минимум $_temp0';
  }

  @override
  String get changeText => 'Изменить';

  @override
  String get changePhotoText => 'Изменить фото';

  @override
  String get fullNameEditDescription =>
      'Помогите людям найти вашу учетную запись, используя имя, под которым вы известны: полное имя, псевдоним или название компании.\n\nВы можете изменить свое имя только дважды в течение 14 дней.';

  @override
  String usernameEditDescription(String username) {
    return 'Вы сможете изменить свое имя пользователя обратно на $username следующие 14 дней.';
  }

  @override
  String profileInfoEditConfirmationText(
      String newUsername, String changeType) {
    return 'Вы уверены что хотите сменить $changeType на $newUsername ?';
  }

  @override
  String profileInfoChangePeriodText(String changeType, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней',
      few: '$count дня',
      one: 'день',
    );
    return 'Вы можете изменять $changeType только дважды в $_temp0.';
  }

  @override
  String get forgotPasswordText => 'Забыли пароль?';

  @override
  String get recoveryPasswordText => 'Восстановление пароля';

  @override
  String get orText => 'Или';

  @override
  String signInWithText(String provider) {
    return 'Войти через $provider';
  }

  @override
  String get goBackConfirmationText => 'Вы уверены что хотите вернуться назад?';

  @override
  String get goBackText => 'Вернуться назад';

  @override
  String get furtherText => 'Далее';

  @override
  String get somethingWentWrongText => 'Что-то пошло не так!';

  @override
  String get failedToCreateStoryText => 'Не удалось создать историю';

  @override
  String get successfullyCreatedStoryText => 'История успешно создана!';

  @override
  String get createText => 'Cоздать';

  @override
  String get reelText => 'Видео Reels';

  @override
  String get postText => 'Публикация';

  @override
  String get storyText => 'История';

  @override
  String get removeText => 'Удалить';

  @override
  String get removeFollowerText => 'Удалить подписчика';

  @override
  String get removeFollowerConfirmationText =>
      'Вы уверены что хотите удалить подписчика?';

  @override
  String get deletePostText => 'Удалить публикацию';

  @override
  String get deletePostConfirmationText =>
      'Вы уверены что хотите удальть эту публикацию?';

  @override
  String get cancelText => 'Отмена';

  @override
  String get captionText => 'Описание';

  @override
  String get noCameraFoundText => 'Камера не найдена!';

  @override
  String get videoText => 'ВИДЕО';

  @override
  String get photoText => 'ФОТО';

  @override
  String get clearImagesText => 'Очистить выбранные изображения';

  @override
  String get galleryText => 'ГАЛЕРЕЯ';

  @override
  String get deletingText => 'УДАЛИТЬ';

  @override
  String get notFoundingCameraText => 'Дополнительная камера не найдена';

  @override
  String get holdButtonText => 'Нажмите и удерживайте, чтобы записать';

  @override
  String get noImagesFoundedText => 'Нет изображений';

  @override
  String get acceptAllPermissionsText => 'Примите все необходимые разрешения!';

  @override
  String get noLastMessagesText => 'Нет последних сообщений';

  @override
  String get onlineText => 'онлайн';

  @override
  String get moreText => 'Ещё';

  @override
  String get noAccountText => 'Ещё нет аккаунта?';

  @override
  String get alreadyHaveAccountText => 'Уже есть аккаунт?';

  @override
  String get nameText => 'Имя';

  @override
  String get usernameText => 'Имя пользователя';

  @override
  String get forgotPasswordEmailConfirmationText =>
      'Подтверждение учётной записи';

  @override
  String verificationTokenSentText(String email) {
    return 'Код подтверждения отправлени на почту $email';
  }

  @override
  String get emailText => 'Почта';

  @override
  String get otpText => 'Код';

  @override
  String get changePasswordText => 'Поменять пароль';

  @override
  String get passwordText => 'Пароль';

  @override
  String get newPasswordText => 'Новый пароль';

  @override
  String get loginText => 'Войти';

  @override
  String get signUpText => 'Зарегестрироваться';

  @override
  String get bioText => 'Биография';

  @override
  String get postUnavailableText => 'Пост недоступен';

  @override
  String get postUnavailableDescriptionText => 'Этот пост недоступен';

  @override
  String get editText => 'Редактировать';

  @override
  String get editedText => 'изменено';

  @override
  String get deleteText => 'Удалить';

  @override
  String get replyText => 'Ответить';

  @override
  String replyToText(Object username) {
    return 'В ответ $username';
  }

  @override
  String get themeText => 'Тема';

  @override
  String get systemOption => 'Системная';

  @override
  String get lightModeOption => 'Светлая';

  @override
  String get darkModeOption => 'Тёмная';

  @override
  String get languageText => 'Язык';

  @override
  String get ruOptionText => 'Русский';

  @override
  String get enOptionText => 'Английский';

  @override
  String secondsAgo(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds секунд назад',
      few: '$seconds секунды назад',
      one: '$seconds секунду назад',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes минут назад',
      few: '$minutes минуты назад',
      one: '$minutes минуту назад',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours часов назад',
      few: '$hours часа назад',
      one: '$hours час назад',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дней назад',
      few: '$days дня назад',
      one: '$days день назад',
    );
    return '$_temp0';
  }

  @override
  String weeksAgo(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks недель назад',
      few: '$weeks недели назад',
      one: '$weeks неделю назад',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months месяцев назад',
      few: '$months месяца назад',
      one: '$months месяц назад',
    );
    return '$_temp0';
  }

  @override
  String yearsAgo(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years лет назад',
      few: '$years года назад',
      one: '$years год назад',
    );
    return '$_temp0';
  }

  @override
  String get networkError =>
      'Произошла сетевая ошибка.\nПроверьте подключение и повторите попытку.';

  @override
  String get networkErrorButton => 'Попробуйте ещё раз';
}
