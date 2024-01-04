part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

final class ChatMessagesSubscriptionRequested extends ChatEvent {
  const ChatMessagesSubscriptionRequested();
}

final class ChatSendMessageRequested extends ChatEvent {
  const ChatSendMessageRequested({
    required this.sender,
    required this.receiver,
    required this.message,
  });

  final User sender;
  final User receiver;
  final Message message;
}

final class ChatMessageDeleteRequested extends ChatEvent {
  const ChatMessageDeleteRequested(this.messageId);

  final String messageId;
}

final class ChatMessageSeen extends ChatEvent {
  const ChatMessageSeen(this.messageId);

  final String messageId;
}

final class ChatMessageEditRequested extends ChatEvent {
  const ChatMessageEditRequested({
    required this.newMessage,
    required this.oldMessage,
  });

  final Message oldMessage;
  final Message newMessage;

  @override
  List<Object> get props => [oldMessage, newMessage];
}
