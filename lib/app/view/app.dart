import 'package:app_ui/app_ui.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:firebase_config/firebase_config.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
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
    required this.userRepository,
    required this.postsRepository,
    required this.chatsRepository,
    required this.storiesRepository,
    required this.searchRepository,
    required this.notificationsClient,
    required this.remoteConfig,
    required this.user,
    super.key,
  });

  final UserRepository userRepository;
  final PostsRepository postsRepository;
  final ChatsRepository chatsRepository;
  final StoriesRepository storiesRepository;
  final SearchRepository searchRepository;
  final FirebaseNotificationsClient notificationsClient;
  final FirebaseConfig remoteConfig;
  final User user;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: postsRepository),
        RepositoryProvider.value(value: chatsRepository),
        RepositoryProvider.value(value: storiesRepository),
        RepositoryProvider.value(value: searchRepository),
        RepositoryProvider.value(value: notificationsClient),
        RepositoryProvider.value(value: remoteConfig),
      ],
      child: BlocProvider(
        create: (context) => AppBloc(
          userRepository: context.read<UserRepository>(),
          user: user,
          notificationsClient: notificationsClient,
        )..add(const AppOpened()),
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

/// Closes all snack bars.
void closeSnackbars() => snackbarKey.currentState?.closeAll();

void showCurrentlyUnavailableFeature({bool clearIfQueue = true}) =>
    openSnackbar(
      const SnackbarMessage.error(
        title: 'Feature is not avaliable!',
        description:
            'We are trying our best to implement it as fast as possible.',
        icon: Icons.error_outline,
      ),
      clearIfQueue: clearIfQueue,
    );
