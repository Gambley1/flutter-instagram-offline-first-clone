import 'package:database_client/database_client.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

/// {@template chats_repository}
/// A repository that manages the chats data data flow.
/// {@endtemplate}
class ChatsRepository implements ChatsBaseRepository {
  /// {@macro chats_repository}
  const ChatsRepository({required DatabaseClient databaseClient})
      : _databaseClient = databaseClient;

  final DatabaseClient _databaseClient;

  @override
  Stream<List<ChatInbox>> chatsOf({required String userId}) =>
      _databaseClient.chatsOf(userId: userId);

  @override
  Future<ChatInbox> getChat({required String chatId, required String userId}) =>
      _databaseClient.getChat(chatId: chatId, userId: userId);

  @override
  Stream<List<Message>> messagesOf({required String chatId}) =>
      _databaseClient.messagesOf(chatId: chatId);

  @override
  Future<void> createChat({
    required String userId,
    required String participantId,
  }) =>
      _databaseClient.createChat(userId: userId, participantId: participantId);

  @override
  Future<void> deleteChat({required String chatId, required String userId}) =>
      _databaseClient.deleteChat(chatId: chatId, userId: userId);

  @override
  Future<void> deleteMessage({required String messageId}) =>
      _databaseClient.deleteMessage(messageId: messageId);

  @override
  Future<void> readMessage({
    required String messageId,
  }) =>
      _databaseClient.readMessage(messageId: messageId);

  @override
  Future<void> sendMessage({
    required String chatId,
    required User sender,
    required User receiver,
    required Message message,
    PostAuthor? postAuthor,
  }) =>
      _databaseClient.sendMessage(
        chatId: chatId,
        sender: sender,
        receiver: receiver,
        message: message,
        postAuthor: postAuthor,
      );

  @override
  Future<void> editMessage({
    required Message oldMessage,
    required Message newMessage,
  }) =>
      _databaseClient.editMessage(
        oldMessage: oldMessage,
        newMessage: newMessage,
      );
}
