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
    on<ChatsSubscriptionRequested>(_onChatsSubscriptionRequested);
    on<ChatsCreateChatRequested>(_onChatsCreateChatRequested);
    on<ChatsDeleteChatRequested>(_onChatsDeleteChatRequested);
  }

  final ChatsRepository _chatsRepository;

  Future<void> _onChatsSubscriptionRequested(
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
  ) async {
    try {
      await _chatsRepository.createChat(
        userId: event.userId,
        participantId: event.participantId,
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  Future<void> _onChatsDeleteChatRequested(
    ChatsDeleteChatRequested event,
    Emitter<ChatsState> emit,
  ) async {
    try {
      await _chatsRepository.deleteChat(
        chatId: event.chatId,
        userId: event.userId,
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }
}
