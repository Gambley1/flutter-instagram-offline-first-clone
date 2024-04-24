import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

class ChatProps extends Equatable {
  const ChatProps({required this.chat});

  final ChatInbox chat;

  @override
  List<Object?> get props => [chat];
}
