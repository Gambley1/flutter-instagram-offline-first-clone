import 'package:app_ui/app_ui.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';

class AppView extends StatelessWidget {
  const AppView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Instagram Clone',
      // home: const ChatPage(
      //   chatId: '6db9b9ca-d1ad-47d3-961f-7b3f5357edd8',
      //   chat: ChatInbox(
      //     id: '6db9b9ca-d1ad-47d3-961f-7b3f5357edd8',
      //     participant: User(
      //       id: 'f918043c-30e0-4f86-9894-34e6844d4e8f',
      //       username: 'emo.official',
      //       avatarUrl:
      //           'https://wefeasvyrksvvywqgchk.supabase.co/storage/v1/object/sign/avatars/2023-12-06T00:50:45.298421.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJhdmF0YXJzLzIwMjMtMTItMDZUMDA6NTA6NDUuMjk4NDIxLmpwZyIsImlhdCI6MTcwMTgwMjI0NywiZXhwIjoyMDE3MTYyMjQ3fQ.-Jt3JWJV1lWU4dli0zy0uNEapCTzmnq6Sb9wtdCgN9M',
      //     ),
      //   ),
      // ),
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
        // textTheme: const AppTheme().textTheme,
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
