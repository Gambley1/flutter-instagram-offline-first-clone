// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

/// {@template chat_inbox}
/// The representation of the Instagram chat inbox. Typically the conversation
/// between two people.
/// {@endtemplate}
class ChatInbox extends Equatable {
  /// {@macro chat_inbox}
  const ChatInbox({
    required this.id,
    required this.participant,
    this.unreadMessagesCount = 0,
    this.lastMessage,
  });

  /// The identifier of the chat.
  final String id;

  /// The last message of the chat inbox.
  final String? lastMessage;

  /// The count of the unread messages in the associated conversation.
  final int unreadMessagesCount;

  /// The participant of the chat.
  final User participant;

  @override
  List<Object?> get props =>
      [id, participant, lastMessage, unreadMessagesCount];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'last_message': lastMessage,
      'unread_messages_count': unreadMessagesCount,
      'participant': participant.toJson(),
    };
  }

  factory ChatInbox.fromRow(Map<String, dynamic> row) {
    return ChatInbox(
      id: row['id'] as String,
      lastMessage: row['last_message'] as String?,
      unreadMessagesCount: row['unread_messages_count'] as int? ?? 0,
      participant: User.fromParticipant(row),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatInbox.fromMap(Map<String, dynamic> map) {
    return ChatInbox(
      id: map['id'] as String,
      lastMessage: map['last_message'] as String?,
      unreadMessagesCount: map['unread_messages_count'] as int? ?? 0,
      participant: User.fromJson(map['participant'] as Map<String, dynamic>),
    );
  }

  factory ChatInbox.fromJson(String source) =>
      ChatInbox.fromMap(json.decode(source) as Map<String, dynamic>);
}

enum ChatType {
  oneOnOne('one-on-one'),
  group('group');

  const ChatType(this.value);

  final String value;
}

extension ChatTypeX on String {
  ChatType get toChatType {
    for (final type in ChatType.values) {
      if (this == type.value) {
        return type;
      }
    }
    logD(
      'Could not establish the chat type. The original string: $this. \n'
      'Returns the default chat type: ${ChatType.oneOnOne.value}',
    );
    return ChatType.oneOnOne;
  }
}
