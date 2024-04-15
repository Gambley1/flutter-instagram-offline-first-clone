import 'package:chats_repository/chats_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'chat_bloc.g.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends HydratedBloc<ChatEvent, ChatState> {
  ChatBloc({required String chatId, required ChatsRepository chatsRepository})
      : _chatId = chatId,
        _chatsRepository = chatsRepository,
        super(const ChatState.initial()) {
    on<ChatMessagesSubscriptionRequested>(_onSubscriptionRequested);
    on<ChatSendMessageRequested>(_onSendMessageRequested);
    on<ChatMessageDeleteRequested>(_onMessageDeleteRequested);
    on<ChatMessageSeen>(_onMessageSeen);
    on<ChatMessageEditRequested>(_onChatMessageEditRequested);
  }

  final String _chatId;
  final ChatsRepository _chatsRepository;

  @override
  String get id => _chatId;

  void _onSubscriptionRequested(
    ChatMessagesSubscriptionRequested event,
    Emitter<ChatState> emit,
  ) =>
      emit.forEach<List<Message>>(
        _chatsRepository.messagesOf(chatId: _chatId),
        onData: (messages) =>
            state.copyWith(messages: messages, status: ChatStatus.success),
        onError: (error, stackTrace) {
          addError(error, stackTrace);
          return state.copyWith(status: ChatStatus.failure);
        },
      );

  Future<void> _onSendMessageRequested(
    ChatSendMessageRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatsRepository.sendMessage(
        chatId: _chatId,
        sender: event.sender,
        receiver: event.receiver,
        message: event.message,
      );
      emit(state.copyWith(status: ChatStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }

  Future<void> _onMessageDeleteRequested(
    ChatMessageDeleteRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatsRepository.deleteMessage(messageId: event.messageId);
      emit(state.copyWith(status: ChatStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }

  Future<void> _onMessageSeen(
    ChatMessageSeen event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatsRepository.readMessage(messageId: event.messageId);
      emit(state.copyWith(status: ChatStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }

  Future<void> _onChatMessageEditRequested(
    ChatMessageEditRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatsRepository.editMessage(
        oldMessage: event.oldMessage,
        newMessage: event.newMessage,
      );
      emit(state.copyWith(status: ChatStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }

  @override
  ChatState? fromJson(Map<String, dynamic> json) => ChatState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ChatState state) => state.toJson();
}
