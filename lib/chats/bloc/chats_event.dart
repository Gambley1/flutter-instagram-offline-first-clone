part of 'chats_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

final class ChatsSubscriptionRequested extends ChatEvent {
  const ChatsSubscriptionRequested({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

final class ChatsCreateChatRequested extends ChatEvent {
  const ChatsCreateChatRequested({
    required this.userId,
    required this.participantId,
  });

  final String userId;
  final String participantId;

  @override
  List<Object> get props => [userId, participantId];
}

final class ChatsDeleteChatRequested extends ChatEvent {
  const ChatsDeleteChatRequested({
    required this.userId,
    required this.chatId,
  });

  final String userId;
  final String chatId;

  @override
  List<Object> get props => [userId, chatId];
}
