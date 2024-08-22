// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/auth/auth.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/chat.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reels.dart';
import 'package:flutter_instagram_offline_first_clone/search/search.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/timeline/timeline.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart' hide FeedPage, ReelsPage;
import 'package:stories_editor/stories_editor.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  const AppRouter(this.appBloc);

  final AppBloc appBloc;

  GoRouter get router => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: AppRoutes.feed.route,
        routes: [
          GoRoute(
            path: AppRoutes.auth.route,
            name: AppRoutes.auth.name,
            builder: (context, state) => const AuthPage(),
          ),
          GoRoute(
            path: AppRoutes.userProfile.path!,
            name: AppRoutes.userProfile.name,
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final userId = state.pathParameters['user_id']!;
              final props = state.extra as UserProfileProps?;

              return CustomTransitionPage(
                key: state.pageKey,
                child: BlocProvider(
                  create: (context) => CreateStoriesBloc(
                    storiesRepository: context.read<StoriesRepository>(),
                    firebaseRemoteConfigRepository:
                        context.read<FirebaseRemoteConfigRepository>(),
                  ),
                  child: UserProfilePage(
                    userId: userId,
                    props: props ?? const UserProfileProps.build(),
                  ),
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: AppRoutes.chat.path!,
            name: AppRoutes.chat.name,
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final chatId = state.pathParameters['chat_id']!;
              final props = state.extra! as ChatProps;

              return CustomTransitionPage(
                key: state.pageKey,
                child: ChatPage(chatId: chatId, chat: props.chat),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: AppRoutes.post.path!,
            name: AppRoutes.post.name,
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'];

              return CustomTransitionPage(
                key: state.pageKey,
                child: PostPreviewPage(id: id ?? ''),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.vertical,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: AppRoutes.postEdit.path!,
            name: AppRoutes.postEdit.name,
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final post = state.extra! as PostBlock;

              return NoTransitionPage(child: PostEditPage(post: post));
            },
          ),
          GoRoute(
            path: AppRoutes.stories.path!,
            name: AppRoutes.stories.name,
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final props = state.extra! as StoriesProps;

              return CustomTransitionPage(
                key: state.pageKey,
                child: StoriesPage(props: props),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.scaled,
                    child: child,
                  );
                },
              );
            },
          ),
          StatefulShellRoute.indexedStack(
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state, navigationShell) {
              return HomePage(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.feed.route,
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const FeedPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.timeline.route,
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const TimelinePage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: CurveTween(
                              curve: Curves.easeInOut,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        name: AppRoutes.search.name,
                        path: AppRoutes.search.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final withResult = state.extra as bool?;

                          return NoTransitionPage(
                            key: state.pageKey,
                            child: SearchPage(withResult: withResult),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  /// This route doesn't return anything and doesn't throws an
                  /// Exception, because we ignore it if we tap of 2nd tab in
                  /// bottom nav bar. Instead, we execute a function to switch
                  /// a page in the `PageView`.
                  GoRoute(
                    path: AppRoutes.createMedia.route,
                    redirect: (context, state) => null,
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.reels.route,
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const ReelsView(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: CurveTween(
                              curve: Curves.easeInOut,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.user.route,
                    pageBuilder: (context, state) {
                      final user =
                          context.select((AppBloc bloc) => bloc.state.user);

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: UserProfilePage(userId: user.id),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        path: AppRoutes.createPost.name,
                        name: AppRoutes.createPost.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final pickVideo = state.extra as bool? ?? false;

                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: UserProfileCreatePost(
                              pickVideo: pickVideo,
                              wantKeepAlive: false,
                            ),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SharedAxisTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.horizontal,
                                child: child,
                              );
                            },
                          );
                        },
                        routes: [
                          GoRoute(
                            name: AppRoutes.publishPost.name,
                            path: AppRoutes.publishPost.name,
                            parentNavigatorKey: _rootNavigatorKey,
                            pageBuilder: (context, state) {
                              final props = state.extra! as CreatePostProps;

                              return CustomTransitionPage(
                                key: state.pageKey,
                                child: CreatePostPage(props: props),
                                transitionsBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return SharedAxisTransition(
                                    animation: animation,
                                    secondaryAnimation: secondaryAnimation,
                                    transitionType:
                                        SharedAxisTransitionType.horizontal,
                                    child: child,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: AppRoutes.createStories.name,
                        name: AppRoutes.createStories.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final onDone =
                              state.extra as dynamic Function(String)?;

                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: StoriesEditor(
                              onDone: onDone,
                              storiesEditorLocalizationDelegate:
                                  storiesEditorLocalizationDelegate(context),
                              galleryThumbnailQuality: 900,
                            ),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SharedAxisTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType: SharedAxisTransitionType.scaled,
                                child: child,
                              );
                            },
                          );
                        },
                      ),
                      GoRoute(
                        path: AppRoutes.editProfile.name,
                        name: AppRoutes.editProfile.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: const UserProfileEdit(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SharedAxisTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.vertical,
                                child: child,
                              );
                            },
                          );
                        },
                        routes: [
                          GoRoute(
                            path: AppRoutes.editProfileInfo.path!,
                            name: AppRoutes.editProfileInfo.name,
                            parentNavigatorKey: _rootNavigatorKey,
                            pageBuilder: (context, state) {
                              final query = state.uri.queryParameters;
                              final label = state.pathParameters['label']!;
                              final appBarTitle = query['title']!;
                              final description = query['description'];
                              final infoValue = query['value'];
                              final infoType =
                                  state.extra as ProfileEditInfoType?;

                              return MaterialPage<void>(
                                fullscreenDialog: true,
                                child: ProfileInfoEditPage(
                                  appBarTitle: appBarTitle,
                                  description: description,
                                  infoValue: infoValue,
                                  infoLabel: label,
                                  infoType: infoType!,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: AppRoutes.userPosts.name,
                        name: AppRoutes.userPosts.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final userId = state.uri.queryParameters['user_id']!;
                          final index = (state.uri.queryParameters['index']!)
                              .parse
                              .toInt();

                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: BlocProvider(
                              create: (context) => UserProfileBloc(
                                userId: userId,
                                userRepository: context.read<UserRepository>(),
                                postsRepository:
                                    context.read<PostsRepository>(),
                              ),
                              child: UserProfilePosts(
                                userId: userId,
                                index: index,
                              ),
                            ),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SharedAxisTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.horizontal,
                                child: child,
                              );
                            },
                          );
                        },
                      ),
                      GoRoute(
                        path: AppRoutes.userStatistics.name,
                        name: AppRoutes.userStatistics.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final userId = state.uri.queryParameters['user_id']!;
                          final tabIndex = state.extra! as int;

                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: BlocProvider(
                              create: (context) => UserProfileBloc(
                                userId: userId,
                                userRepository: context.read<UserRepository>(),
                                postsRepository:
                                    context.read<PostsRepository>(),
                              )
                                ..add(const UserProfileSubscriptionRequested())
                                ..add(
                                  const UserProfileFollowingsCountSubscriptionRequested(),
                                )
                                ..add(
                                  const UserProfileFollowersCountSubscriptionRequested(),
                                ),
                              child: UserProfileStatistics(tabIndex: tabIndex),
                            ),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SharedAxisTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.horizontal,
                                child: child,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
        redirect: (context, state) {
          final authenticated = appBloc.state.status == AppStatus.authenticated;
          final authenticating = state.matchedLocation == AppRoutes.auth.route;
          final isInFeed = state.matchedLocation == AppRoutes.feed.route;

          if (isInFeed && !authenticated) return AppRoutes.auth.route;
          if (!authenticated) return AppRoutes.auth.route;
          if (authenticating && authenticated) return AppRoutes.feed.route;

          return null;
        },
        refreshListenable: GoRouterAppBlocRefreshStream(appBloc.stream),
      );
}

/// {@template go_router_refresh_stream}
/// A [ChangeNotifier] that notifies listeners when a [Stream] emits a value.
/// This is used to rebuild the UI when the [AppBloc] emits a new state.
/// {@endtemplate}
class GoRouterAppBlocRefreshStream extends ChangeNotifier {
  /// {@macro go_router_refresh_stream}
  GoRouterAppBlocRefreshStream(Stream<AppState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((appState) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
