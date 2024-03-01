// ignore_for_file: avoid_positional_boolean_parameters

import 'package:app_ui/app_ui.dart';
import 'package:firebase_config/firebase_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chats.dart';
import 'package:flutter_instagram_offline_first_clone/navigation/navigation.dart';
import 'package:flutter_instagram_offline_first_clone/stories/create_stories/create_stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';

class HomeProvider extends ChangeNotifier {
  factory HomeProvider() => _internal;

  HomeProvider._();

  static final _internal = HomeProvider._();

  late PageController pageController;

  void setPageController(PageController controller) {
    pageController = controller;
    notifyListeners();
  }

  void animateToPage(int page) => pageController.animateToPage(
        page,
        curve: Easing.legacy,
        duration: 150.ms,
      );

  bool enablePageView = true;

  void togglePageView({bool enable = true}) {
    enablePageView = enable;
    notifyListeners();
  }
}

/// {@template home_view}
/// Main view of the application. It contains the [navigationShell] that will
/// handle the navigation between the different bottom navigation bars.
/// {@endtemplate}
class HomeView extends StatefulWidget {
  /// {@macro home_view}
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeProvider().setPageController(_pageController);
    });
  }

  void _onPageScroll() {
    _pageController.position.isScrollingNotifier.addListener(_isPageScrolling);
  }

  void _isPageScrolling() {
    final isScrolling =
        _pageController.position.isScrollingNotifier.value == true;
    final mainPageView = _pageController.page == 1;
    final navigationBarIndex = widget.navigationShell.currentIndex;
    final isFeed = !isScrolling && mainPageView && navigationBarIndex == 0;
    final isTimeline = !isScrolling && mainPageView && navigationBarIndex == 1;
    final isReels = !isScrolling && mainPageView && navigationBarIndex == 3;

    if (isScrolling) {
      _videoPlayerState.stopAll();
    }
    switch ((isFeed, isTimeline, isReels)) {
      case (true, false, false):
        _videoPlayerState.playFeed();
      case (false, true, false):
        _videoPlayerState.playTimeline();
      case (false, false, true):
        _videoPlayerState.playReels();
      case _:
        _videoPlayerState.stopAll();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.navigationShell.currentIndex == 0 &&
        !HomeProvider().enablePageView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HomeProvider().togglePageView();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateStoriesBloc(
        storiesRepository: context.read<StoriesRepository>(),
        remoteConfig: context.read<FirebaseConfig>(),
      )..add(const CreateStoriesIsFeatureAvaiableSubscriptionRequested()),
      child: VideoPlayerProvider(
        videoPlayerState: _videoPlayerState,
        child: ListenableBuilder(
          listenable: HomeProvider(),
          builder: (context, child) {
            return PageView.builder(
              itemCount: 3,
              controller: _pageController,
              physics: HomeProvider().enablePageView
                  ? null
                  : const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                if (page != 0 && page != 2 && page == 1) {
                  customImagePickerKey.currentState?.resetAll();
                }
                if (page == 1 && widget.navigationShell.currentIndex != 0) {
                  HomeProvider().togglePageView(enable: false);
                }
              },
              itemBuilder: (context, index) {
                return switch (index) {
                  0 => UserProfileCreatePost(
                      imagePickerKey: customImagePickerKey,
                      onPopInvoked: () => HomeProvider().animateToPage(1),
                      onBackButtonTap: () => HomeProvider().animateToPage(1),
                    ),
                  2 => const ChatsPage(),
                  _ => AppScaffold(
                      body: widget.navigationShell,
                      bottomNavigationBar:
                          BottomNavBar(navigationShell: widget.navigationShell),
                    ),
                };
              },
            );
          },
        ),
      ),
    );
  }
}

class VideoPlayerProvider extends InheritedWidget {
  const VideoPlayerProvider({
    required this.videoPlayerState,
    required super.child,
    super.key,
  });

  final VideoPlayerState videoPlayerState;

  @override
  bool updateShouldNotify(VideoPlayerProvider oldWidget) =>
      videoPlayerState != oldWidget.videoPlayerState;

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

  final enablePageView = ValueNotifier(true);
  final shouldPlayFeed = ValueNotifier(true);
  final shouldPlayReels = ValueNotifier(true);
  final shouldPlayTimeline = ValueNotifier(true);
  final withSound = ValueNotifier(false);

  // ignore: use_setters_to_change_properties
  void togglePageView({bool enable = true}) {
    enablePageView.value = enable;
  }

  void playFeed() {
    shouldPlayFeed.value = true;
    shouldPlayReels.value = false;
    shouldPlayTimeline.value = false;
  }

  void playTimeline() {
    shouldPlayFeed.value = false;
    shouldPlayReels.value = false;
    shouldPlayTimeline.value = true;
  }

  void playReels() {
    shouldPlayFeed.value = false;
    shouldPlayReels.value = true;
    shouldPlayTimeline.value = false;
  }

  void stopAll() {
    shouldPlayFeed.value = false;
    shouldPlayReels.value = false;
    shouldPlayTimeline.value = false;
  }
}

enum VideoPlayerType { feed, timeline, reels }

class VideoPlayerNotifierWidget extends StatefulWidget {
  const VideoPlayerNotifierWidget({
    required this.type,
    required this.builder,
    this.id,
    this.checkIsInView,
    this.child,
    super.key,
  });

  final VideoPlayerType type;
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
  late ValueNotifier<bool> _shouldPlayType;

  @override
  void initState() {
    super.initState();
    _videoPlayerState = VideoPlayerProvider.of(context).videoPlayerState;
    _shouldPlayType = switch (widget.type) {
      VideoPlayerType.feed => _videoPlayerState.shouldPlayFeed,
      VideoPlayerType.reels => _videoPlayerState.shouldPlayReels,
      VideoPlayerType.timeline => _videoPlayerState.shouldPlayTimeline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _shouldPlayType,
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
