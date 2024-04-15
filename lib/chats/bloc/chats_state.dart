// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chats_bloc.dart';

enum ChatsStatus { initial, loading, populated, failure }

class ChatsState extends Equatable {
  const ChatsState._({
    required this.status,
    required this.chats,
  });

  const ChatsState.initial()
      : this._(status: ChatsStatus.initial, chats: const []);

  final ChatsStatus status;
  final List<ChatInbox> chats;

  @override
  List<Object> get props => [status, chats];

  ChatsState copyWith({
    ChatsStatus? status,
    List<ChatInbox>? chats,
  }) {
    return ChatsState._(
      status: status ?? this.status,
      chats: chats ?? this.chats,
    );
  }
}
