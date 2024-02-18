import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/selector/selector.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleBloc>().state;
    final themeMode = context.watch<ThemeModeBloc>().state;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => LocaleSettings.setLocaleRaw(locale.languageCode),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Instagram',
      routerConfig: router(context.read<AppBloc>()),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            AppSnackbar(key: snackbarKey),
            ApplLoadingIndeterminate(key: loadingIndeterminateKey),
          ],
        );
      },
      themeMode: themeMode,
      theme: const AppTheme().theme,
      darkTheme: const AppDarkTheme().theme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
