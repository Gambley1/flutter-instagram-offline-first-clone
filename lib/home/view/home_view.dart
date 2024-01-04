import 'package:app_ui/app_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/navigation/navigation.dart';
import 'package:go_router/go_router.dart';

/// {@template main_view}
/// Main view of the application. It contains the [navigationShell] that will
/// handle the navigation between the different bottom navigation bars.
/// {@endtemplate}
class HomeView extends StatefulWidget {
  /// {@macro main_view}
  const HomeView({required this.navigationShell, Key? key})
      : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// Navigation shell that will handle the navigation between the different
  /// bottom navigation bars.
  final StatefulNavigationShell navigationShell;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<void> setupInteractedMessage(BuildContext context) async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    if (message.data['chat_id'] != null) {
      final user = context.read<AppBloc>().state.user;
      if (user.isAnonymous) return;
      // final chat = await context
      //     .read<ChatsRepository>()
      //     .getChat(chatId: message.data['chat_id']! as String, userId: user.id);
      // await router(context.read<AppBloc>()).pushNamed(
      // 'chat',
      // pathParameters: {'chat_id': message.data['chat_id']! as String},
      // queryParameters: {'chat': chat.toJson()},
      // );
    }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: widget.navigationShell,
      bottomNavigationBar:
          BottomNavBar(navigationShell: widget.navigationShell),
    );
  }
}
