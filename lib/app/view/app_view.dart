import 'dart:async';
import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/selector/selector.dart';
import 'package:shared/shared.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final routerConfig = router(context.read<AppBloc>());

    return BlocBuilder<LocaleBloc, Locale>(
      builder: (context, locale) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => LocaleSettings.setLocaleRaw(locale.languageCode),
        );
        return BlocBuilder<ThemeModeBloc, ThemeMode>(
          builder: (context, themeMode) {
            return AnimatedSwitcher(
              duration: 350.ms,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Instagram',
                  routerConfig: routerConfig,
                  builder: (context, child) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => initUtilities(context, locale),
                    );

                    return Stack(
                      children: [
                        child!,
                        AppSnackbar(key: snackbarKey),
                        AppLoadingIndeterminate(key: loadingIndeterminateKey),
                      ],
                    );
                  },
                  themeMode: themeMode,
                  theme: const AppTheme().theme,
                  darkTheme: const AppDarkTheme().theme,
                  locale: locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRunning = false;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} ${_isRunning ? "- Running" : ""}'),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * pi,
              child: child,
            );
          },
          child: const FlutterLogo(size: 200),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _isRunning = true;
          });
          await run();
          setState(() {
            _isRunning = false;
          });
        },
        child: const Icon(Icons.run_circle),
      ),
    );
  }
}

Future<void> run() async {
  final dt = DateTime.now();
  // run1();
  await run2();
  logD(
    (DateTime.now().millisecondsSinceEpoch - dt.millisecondsSinceEpoch) / 1000,
  );
}

Future<void> run1() async {
  var str = '';
  for (var i = 0; i < 40000; i++) {
    str = '$str $i';
  }
  logD(str);
}

Future<void> run2() async {
  var str = '';
  await runLoop(
    length: 40000,
    execute: (index) => str = '$str $index',
  );
  logD(str);
}

Future<bool> runLoop({
  required int length,
  required void Function(int index) execute,
  int chunkLength = 25,
}) {
  final completer = Completer<bool>();
  // ignore: omit_local_variable_types
  void Function(int i) exec = (i) {};
  exec = (i) {
    if (i >= length) return completer.complete(true);
    for (var j = i; j < min(length, i + chunkLength); j++) {
      execute(j);
    }
    Future.delayed(Duration.zero, () {
      exec(i + chunkLength);
    });
  };
  exec(0);
  return completer.future;
}
