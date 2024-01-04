import 'package:chats_repository/chats_repository.dart';
import 'package:database_client/database_client.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/bootstrap.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:supabase_authentication_client/supabase_authentication_client.dart';
import 'package:token_storage/token_storage.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  bootstrap(
    (powerSyncRepository, firebaseMessaging) async {
      final notificationsClient =
          FirebaseNotificationsClient(firebaseMessaging: firebaseMessaging);

      final tokenStorage = InMemoryTokenStorage();

      final authenticationClient = SupabaseAuthenticationClient(
        powerSyncRepository: powerSyncRepository,
        tokenStorage: tokenStorage,
      );

      final client = DatabaseClient(powerSyncRepository);

      final userRepository = UserRepository(
        client: client,
        authenticationClient: authenticationClient,
      );

      final postsRepository = PostsRepository(client: client);

      final chatsRepository = ChatsRepository(client: client);

      return App(
        userRepository: userRepository,
        postsRepository: postsRepository,
        chatsRepository: chatsRepository,
        notificationsClient: notificationsClient,
        user: await userRepository.user.first,
      );
    },
    isDev: false,
  );
}
