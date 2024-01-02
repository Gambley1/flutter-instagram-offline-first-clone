import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/navigation/navigation.dart';
import 'package:go_router/go_router.dart';

/// {@template main_view}
/// Main view of the application. It contains the [navigationShell] that will
/// handle the navigation between the different bottom navigation bars.
/// {@endtemplate}
class HomeView extends StatelessWidget {
  /// {@macro main_view}
  const HomeView({required this.navigationShell, Key? key})
      : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// Navigation shell that will handle the navigation between the different
  /// bottom navigation bars.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(navigationShell: navigationShell),
    );
  }
}
