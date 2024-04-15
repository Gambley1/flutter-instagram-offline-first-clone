import 'package:bloc/bloc.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatEvent, ChatsState> {
  ChatsBloc({required ChatsRepository chatsRepository})
      : _chatsRepository = chatsRepository,
        super(const ChatsState.initial()) {
    on<ChatsSubscriptionRequested>(_onSubscriptionRequested);
    on<ChatsCreateChatRequested>(_onChatsCreateChatRequested);
    on<ChatsDeleteChatRequested>(_onChatsDeleteChatRequested);
  }

  final ChatsRepository _chatsRepository;

  void _onSubscriptionRequested(
    ChatsSubscriptionRequested event,
    Emitter<ChatsState> emit,
  ) =>
      emit.forEach<List<ChatInbox>>(
        _chatsRepository.chatsOf(userId: event.userId),
        onData: (chats) =>
            state.copyWith(chats: chats, status: ChatsStatus.populated),
        onError: (error, stackTrace) {
          addError(error, stackTrace);
          return state.copyWith(status: ChatsStatus.failure);
        },
      );

  Future<void> _onChatsCreateChatRequested(
    ChatsCreateChatRequested event,
    Emitter<ChatsState> emit,
  ) =>
      _chatsRepository.createChat(
        userId: event.userId,
        participantId: event.participantId,
      );

  Future<void> _onChatsDeleteChatRequested(
    ChatsDeleteChatRequested event,
    Emitter<ChatsState> emit,
  ) async =>
      _chatsRepository.deleteChat(chatId: event.chatId, userId: event.userId);
}
