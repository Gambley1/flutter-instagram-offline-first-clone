import 'package:chats_repository/chats_repository.dart';
import 'package:database_client/database_client.dart';
import 'package:env/env.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/bootstrap.dart';
import 'package:flutter_instagram_offline_first_clone/firebase_options_prod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:search_repository/search_repository.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:supabase_authentication_client/supabase_authentication_client.dart';
import 'package:token_storage/token_storage.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  bootstrap(
    (
      powerSyncRepository,
      firebaseMessaging,
      sharedPreferences,
      remoteConfig,
    ) async {
      final notificationsClient =
          FirebaseNotificationsClient(firebaseMessaging: firebaseMessaging);

      final tokenStorage = InMemoryTokenStorage();

      final iosClientId = EnvProd.iOSClientId;
      final webClientId = EnvProd.webClientId;
      final googleSignIn =
          GoogleSignIn(clientId: iosClientId, serverClientId: webClientId);

      final authenticationClient = SupabaseAuthenticationClient(
        powerSyncRepository: powerSyncRepository,
        tokenStorage: tokenStorage,
        googleSignIn: googleSignIn,
      );

      final client = DatabaseClient(powerSyncRepository);

      final persistentStorage =
          PersistentStorage(sharedPreferences: sharedPreferences);

      final storiesStorage = StoriesStorage(storage: persistentStorage);

      final userRepository = UserRepository(
        client: client,
        authenticationClient: authenticationClient,
      );

      final searchRepository = SearchRepository(client: client);

      final postsRepository = PostsRepository(client: client);

      final chatsRepository = ChatsRepository(client: client);

      final storiesRepository =
          StoriesRepository(client: client, storage: storiesStorage);

      return App(
        userRepository: userRepository,
        postsRepository: postsRepository,
        chatsRepository: chatsRepository,
        storiesRepository: storiesRepository,
        searchRepository: searchRepository,
        notificationsClient: notificationsClient,
        remoteConfig: remoteConfig,
        user: await userRepository.user.first,
      );
    },
    options: DefaultFirebaseOptions.currentPlatform,
    isDev: false,
  );
}
