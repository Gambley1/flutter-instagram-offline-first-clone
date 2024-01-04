import 'dart:async';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/auth/auth.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/view/view.dart';
import 'package:flutter_instagram_offline_first_clone/chats/widgets/search_users.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/widgets/post_preview.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reels.dart';
import 'package:flutter_instagram_offline_first_clone/search/search.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart' hide FeedPage;
import 'package:user_repository/user_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter router(AppBloc appBloc) => GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation:
          appBloc.state.status == AppStatus.authenticated ? '/feed' : '/auth',
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthPage(),
        ),
        GoRoute(
          path: '/user/profile/:user_id',
          name: 'user_profile',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['user_id'];
            final isSponsored = (state.extra as bool?) ?? false;
            final promoBlockAction =
                state.uri.queryParameters['promo_action'] == null
                    ? null
                    : BlockAction.fromJson(
                        jsonDecode(state.uri.queryParameters['promo_action']!)
                            as Map<String, dynamic>,
                      );

            return CustomTransitionPage(
              child: UserProfilePage(
                userId: userId,
                isSponsored: isSponsored,
                promoBlockAction: promoBlockAction,
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
          path: '/user/profile/root/:user_id',
          name: 'user_profile_root',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final userId = state.pathParameters['user_id'];
            final isSponsored = (state.extra as bool?) ?? false;
            final promoBlockAction =
                state.uri.queryParameters['promo_action'] == null
                    ? null
                    : BlockAction.fromJson(
                        jsonDecode(state.uri.queryParameters['promo_action']!)
                            as Map<String, dynamic>,
                      );

            return CustomTransitionPage(
              child: UserProfilePage(
                userId: userId,
                isSponsored: isSponsored,
                promoBlockAction: promoBlockAction,
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
          path: '/user/statistics',
          name: 'user_statistics',
          pageBuilder: (context, state) {
            String? userId() {
              final uid = state.uri.queryParameters['user_id'];
              if (uid == null) return null;
              if (uid.isEmpty) return null;
              return uid;
            }

            final tabIndex = (state.extra! as String).parse.toInt();

            return CustomTransitionPage(
              child: BlocProvider(
                create: (context) => UserProfileBloc(
                  userRepository: context.read<UserRepository>(),
                  postsRepository: context.read<PostsRepository>(),
                  userId: userId(),
                )
                  ..add(const UserProfileFollowersRequested())
                  ..add(const UserProfileFollowingsRequested()),
                child: UserProfileStatistics(tabIndex: tabIndex),
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
          path: '/user/posts',
          name: 'user_posts',
          pageBuilder: (context, state) {
            final userId = state.uri.queryParameters['user_id']!;
            final index = (state.uri.queryParameters['index']!).parse.toInt();

            return CustomTransitionPage(
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => UserProfileBloc(
                      userRepository: context.read<UserRepository>(),
                      postsRepository: context.read<PostsRepository>(),
                      userId: userId,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => FeedBloc(
                      postsRepository: context.read<PostsRepository>(),
                      userRepository: context.read<UserRepository>(),
                    ),
                  ),
                ],
                child: UserProfilePosts(
                  userId: userId,
                  index: index,
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
          path: '/chat/:chat_id',
          name: 'chat',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final chatId = state.pathParameters['chat_id']!;
            final chat = ChatInbox.fromJson(state.uri.queryParameters['chat']!);

            return CustomTransitionPage(
              child: ChatPage(chatId: chatId, chat: chat),
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
          path: '/users/search',
          name: 'search_users',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final returnUser = state.extra as bool?;

            return CustomTransitionPage(
              fullscreenDialog: true,
              child: SearchUsers(returnUser: returnUser ?? false),
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
          path: '/posts/details/:id',
          name: 'post_details',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'];

            return CustomTransitionPage(
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
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state, navigationShell) {
            return HomePage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/feed',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: const FeedPage(),
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
                  path: '/search',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: const SearchView(),
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
                  path: '/navigate_create_media',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: AppScaffold(
                        body: Column(
                          children: [
                            const Text('Todo'),
                            AppButton.outlined(
                              text: 'Navigate to profile',
                              onPressed: () =>
                                  context.pushNamed('user_profile'),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
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
                  path: '/reels',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
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
                  path: '/account',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: const UserProfilePage(),
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
                      path: 'create_post',
                      name: 'create_post',
                      pageBuilder: (context, state) {
                        return CustomTransitionPage(
                          child: const UserProfileCreatePost(),
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
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final authenticated = appBloc.state.status == AppStatus.authenticated;
        final authenticating = state.matchedLocation == '/auth';

        if (!authenticated) {
          return '/auth';
        }
        if (authenticating) {
          return '/feed';
        }

        return null;
      },
      refreshListenable: GoRouterAppBlocRefreshStream(appBloc.stream),
    );

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
