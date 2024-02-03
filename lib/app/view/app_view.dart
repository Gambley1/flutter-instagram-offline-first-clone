import 'package:app_ui/app_ui.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Instagram Clone',
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
      themeMode: ThemeMode.dark,
      theme: FlexThemeData.light(
        scheme: FlexScheme.custom,
        colors: FlexSchemeColor.from(
          brightness: Brightness.light,
          primary: Colors.black,
          swapOnMaterial3: true,
        ),
        useMaterial3: true,
        useMaterial3ErrorColors: true,
        appBarStyle: FlexAppBarStyle.scaffoldBackground,
      ).copyWith(
        textTheme: const AppTheme().textTheme,
        iconTheme: const IconThemeData(color: Colors.black),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
        ),
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.custom,
        darkIsTrueBlack: true,
        colors: FlexSchemeColor.from(
          brightness: Brightness.dark,
          primary: Colors.white,
          appBarColor: Colors.transparent,
          swapOnMaterial3: true,
        ),
        useMaterial3: true,
        useMaterial3ErrorColors: true,
      ).copyWith(
        textTheme: const AppDarkTheme().textTheme,
        iconTheme: const IconThemeData(color: Colors.white),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
        ),
      ),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
