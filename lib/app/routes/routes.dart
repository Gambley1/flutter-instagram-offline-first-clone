import 'dart:async';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:firebase_config/firebase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/auth/auth.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/chat.dart';
import 'package:flutter_instagram_offline_first_clone/chats/widgets/search_users.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reels.dart';
import 'package:flutter_instagram_offline_first_clone/search/view/search_view.dart';
import 'package:flutter_instagram_offline_first_clone/stories/create_stories/create_stories.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/timeline/timeline.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart' hide FeedPage;
import 'package:stories_editor/stories_editor.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter router(AppBloc appBloc) => GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/feed',
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
              key: state.pageKey,
              child: BlocProvider(
                create: (context) => CreateStoriesBloc(
                  storiesRepository: context.read<StoriesRepository>(),
                  remoteConfig: context.read<FirebaseConfig>(),
                ),
                child: UserProfilePage(
                  userId: userId,
                  isSponsored: isSponsored,
                  promoBlockAction: promoBlockAction,
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
              key: state.pageKey,
              child: BlocProvider(
                create: (context) => UserProfileBloc(
                  userRepository: context.read<UserRepository>(),
                  postsRepository: context.read<PostsRepository>(),
                  userId: userId(),
                )
                  ..add(const UserProfileFetchFollowersRequested())
                  ..add(const UserProfileFetchFollowingsRequested()),
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
              key: state.pageKey,
              child: BlocProvider(
                create: (context) => UserProfileBloc(
                  userRepository: context.read<UserRepository>(),
                  postsRepository: context.read<PostsRepository>(),
                  userId: userId,
                ),
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
              key: state.pageKey,
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
              key: state.pageKey,
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
          path: '/stories/view',
          name: 'view_stories',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final author = state.extra! as User;
            final stories = fromListJson(state.uri.queryParameters['stories']!);

            return CustomTransitionPage(
              key: state.pageKey,
              child: StoriesPage(stories: stories, author: author),
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
                  path: '/feed',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      key: state.pageKey,
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
                  path: '/timeline',
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
                      name: 'search',
                      path: 'search',
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
                GoRoute(
                  path: '/navigate_create_media',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: AppScaffold(
                        body: Column(
                          children: [
                            const Text('Todo'),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: AppButton.outlined(
                                text: 'Navigate to profile',
                                onPressed: () => context.push('/profile'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
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
                      key: state.pageKey,
                      child: const ReelsPage(),
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
                  path: '/profile',
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
                      path: 'create_post',
                      name: 'create_post',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return CustomTransitionPage(
                          key: state.pageKey,
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
                    GoRoute(
                      path: 'create_stories',
                      name: 'create_stories',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final onDone = state.extra as dynamic Function(String)?;

                        return CustomTransitionPage(
                          key: state.pageKey,
                          child: StoriesEditor(
                            onDone: onDone,
                            galleryThumbnailQuality: 900,
                          ),
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
                    GoRoute(
                      path: 'edit',
                      name: 'edit_profile',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) {
                        return CustomTransitionPage(
                          key: state.pageKey,
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
