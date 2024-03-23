import 'package:app_ui/app_ui.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/selector/selector.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:search_repository/search_repository.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

/// Key to access the [AppSnackbarState] from the [BuildContext].
final snackbarKey = GlobalKey<AppSnackbarState>();

/// Key to access the [AppLoadingIndeterminateState] from the
/// [BuildContext].
final loadingIndeterminateKey = GlobalKey<AppLoadingIndeterminateState>();

class App extends StatelessWidget {
  const App({
    required this.user,
    required this.userRepository,
    required this.postsRepository,
    required this.chatsRepository,
    required this.storiesRepository,
    required this.searchRepository,
    required this.notificationsRepository,
    required this.firebaseRemoteConfigRepository,
    super.key,
  });

  final User user;
  final UserRepository userRepository;
  final PostsRepository postsRepository;
  final ChatsRepository chatsRepository;
  final StoriesRepository storiesRepository;
  final SearchRepository searchRepository;
  final NotificationsRepository notificationsRepository;
  final FirebaseRemoteConfigRepository firebaseRemoteConfigRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: postsRepository),
        RepositoryProvider.value(value: chatsRepository),
        RepositoryProvider.value(value: storiesRepository),
        RepositoryProvider.value(value: searchRepository),
        RepositoryProvider.value(value: notificationsRepository),
        RepositoryProvider.value(value: firebaseRemoteConfigRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppBloc(
              user: user,
              userRepository: userRepository,
              notificationsRepository: notificationsRepository,
            ),
          ),
          BlocProvider(create: (_) => LocaleBloc()),
          BlocProvider(create: (_) => ThemeModeBloc()),
          BlocProvider(
            create: (context) => FeedBloc(
              postsRepository: context.read<PostsRepository>(),
              firebaseRemoteConfigRepository:
                  context.read<FirebaseRemoteConfigRepository>(),
            ),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

/// Snack bar to show messages to the user.
void openSnackbar(
  SnackbarMessage message, {
  bool clearIfQueue = false,
  bool undismissable = false,
}) {
  snackbarKey.currentState
      ?.post(message, clearIfQueue: clearIfQueue, undismissable: undismissable);
}

void toggleLoadingIndeterminate({bool enable = true, bool autoHide = false}) =>
    loadingIndeterminateKey.currentState
        ?.setVisibility(visible: enable, autoHide: autoHide);

/// Closes all snack bars.
void closeSnackbars() => snackbarKey.currentState?.closeAll();

void showCurrentlyUnavailableFeature({bool clearIfQueue = true}) =>
    openSnackbar(
      const SnackbarMessage.error(
        title: 'Feature is not available!',
        description:
            'We are trying our best to implement it as fast as possible.',
        icon: Icons.error_outline,
      ),
      clearIfQueue: clearIfQueue,
    );
