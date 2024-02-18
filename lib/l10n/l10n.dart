import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/generated/generated.dart';

export 'package:flutter_instagram_offline_first_clone/l10n/generated/generated.dart';
export 'package:flutter_instagram_offline_first_clone/l10n/slang/translations.g.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
