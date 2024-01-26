// ignore_for_file: avoid_positional_boolean_parameters

import 'package:app_ui/app_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/navigation/navigation.dart';
import 'package:go_router/go_router.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

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
  late VideoPlayerState _videoPlayerState;
  late PageController _pageController;

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
    }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage(context);

    _pageController = PageController(initialPage: 1)
      ..addListener(_onPageScroll);
    _videoPlayerState = VideoPlayerState();
  }

  void _onPageScroll() {
    _pageController.position.isScrollingNotifier.addListener(_isPageScrolling);
  }

  void _isPageScrolling() {
    if (_pageController.position.isScrollingNotifier.value == true) {
      _videoPlayerState.shouldPlay.value = false;
    } else if (_pageController.position.isScrollingNotifier.value == false &&
        _pageController.page == 1) {
      _videoPlayerState.shouldPlay.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayerProvider(
      videoPlayerState: _videoPlayerState,
      pageController: _pageController,
      child: AppScaffold(
        body: widget.navigationShell,
        bottomNavigationBar:
            BottomNavBar(navigationShell: widget.navigationShell),
      ),
    );
  }
}

class VideoPlayerProvider extends InheritedWidget {
  const VideoPlayerProvider({
    required this.videoPlayerState,
    required this.pageController,
    required super.child,
    super.key,
  });

  final VideoPlayerState videoPlayerState;
  final PageController pageController;

  @override
  bool updateShouldNotify(VideoPlayerProvider oldWidget) =>
      videoPlayerState != oldWidget.videoPlayerState ||
      pageController != oldWidget.pageController;

  static VideoPlayerProvider of(BuildContext context) {
    final provider =
        context.getInheritedWidgetOfExactType<VideoPlayerProvider>();
    assert(provider != null, 'No provider found in context!');
    return provider!;
  }

  static VideoPlayerProvider? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<VideoPlayerProvider>();
}

class VideoPlayerState {
  VideoPlayerState();

  final shouldPlay = ValueNotifier(true);
  final withSound = ValueNotifier(false);
}

class VideoPlayerNotifierWidget extends StatefulWidget {
  const VideoPlayerNotifierWidget({
    required this.builder,
    this.id,
    this.checkIsInView,
    this.child,
    super.key,
  });

  final String? id;
  final bool? checkIsInView;
  final Widget? child;
  final Widget Function(BuildContext context, bool shouldPlay, Widget? child)
      builder;

  @override
  State<VideoPlayerNotifierWidget> createState() => _VideoPlayerNotifierState();
}

class _VideoPlayerNotifierState extends State<VideoPlayerNotifierWidget> {
  late VideoPlayerState _videoPlayerState;

  @override
  void initState() {
    super.initState();
    _videoPlayerState = VideoPlayerProvider.of(context).videoPlayerState;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _videoPlayerState.shouldPlay,
      child: widget.child,
      builder: (context, shoudPlay, child) {
        if (widget.checkIsInView ?? false) {
          return InViewNotifierWidget(
            id: widget.id!,
            builder: (context, isInView, _) {
              final play = isInView && shoudPlay;
              return widget.builder(context, play, child);
            },
          );
        }
        return widget.builder(context, shoudPlay, child);
      },
    );
  }
}
