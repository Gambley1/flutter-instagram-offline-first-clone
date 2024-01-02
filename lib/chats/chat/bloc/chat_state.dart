part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, success, failure }

@JsonSerializable()
class ChatState extends Equatable {
  const ChatState({required this.status, required this.messages});

  factory ChatState.fromJson(Map<String, dynamic> json) =>
      _$ChatStateFromJson(json);

  const ChatState.initial()
      : this(status: ChatStatus.initial, messages: const []);

  final ChatStatus status;
  final List<Message> messages;

  @override
  List<Object> get props => [status, messages];

  ChatState copyWith({
    ChatStatus? status,
    List<Message>? messages,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() => _$ChatStateToJson(this);
}
