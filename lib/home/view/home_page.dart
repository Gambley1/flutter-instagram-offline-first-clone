// ignore_for_file: avoid_positional_boolean_parameters

import 'package:app_ui/app_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chats.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/video/video.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/navigation/navigation.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc(
        userRepository: context.read<UserRepository>(),
        postsRepository: context.read<PostsRepository>(),
      ),
      lazy: false,
      child: HomeView(navigationShell: navigationShell),
    );
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
  late VideoPlayerProvider _videoPlayerProvider;
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
    _videoPlayerProvider = VideoPlayerProvider();

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
      _videoPlayerProvider.stopAll();
    }
    switch ((isFeed, isTimeline, isReels)) {
      case (true, false, false):
        _videoPlayerProvider.playFeed();
      case (false, true, false):
        _videoPlayerProvider.playTimeline();
      case (false, false, true):
        _videoPlayerProvider.playReels();
      case _:
        _videoPlayerProvider.stopAll();
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
        firebaseRemoteConfigRepository:
            context.read<FirebaseRemoteConfigRepository>(),
      )..add(const CreateStoriesIsFeatureAvailableSubscriptionRequested()),
      child: VideoPlayerInheritedWidget(
        videoPlayerProvider: _videoPlayerProvider,
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
                      canPop: false,
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
