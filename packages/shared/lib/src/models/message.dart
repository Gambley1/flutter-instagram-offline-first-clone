// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

/// The type of the message.
enum MessageType {
  /// The message is a typical `text` string.
  text('text'),

  /// The message is a `photo`.
  image('image'),

  /// The message is a `video`.
  video('video'),

  /// The message is a recorded `voice`.
  voice('voice');

  const MessageType(this.value);

  final String value;
}

enum MessageAction {
  edit('edit'),
  reply('reply'),
  delete('delete');

  const MessageAction(this.value);

  final String value;
}

/// {@template message}
/// The representation of the Instagram chat message.
/// {@endtemplate}
class Message extends Equatable {
  /// {@macro message}
  Message({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    this.sender,
    this.type = MessageType.text,
    this.attachments = const [],
    this.message = '',
    String? replyMessageId,
    this.isRead = false,
    this.isDeleted = false,
    this.isEdited = false,
    this.replyMessageUsername,
    this.repliedMessage,
    this.sharedPost,
    String? sharedPostId,
    this.replyMessageAttachmentUrl,
  })  : id = id ?? UidGenerator.v4(),
        createdAt = createdAt ?? Jiffy.now().dateTime,
        updatedAt = updatedAt ?? Jiffy.now().dateTime,
        _replyMessageId = replyMessageId,
        _sharedPostId = sharedPostId;

  /// The identifier of the message.
  final String id;

  /// The sender profile of the message.
  final PostAuthor? sender;

  /// The type of the sent message.
  final MessageType type;

  /// The content of the message.
  final String message;

  /// The identifier of the message this message was replied to.
  final String? _replyMessageId;

  String? get replyMessageId => _replyMessageId ?? repliedMessage?.id;

  /// The name of the user the comment is replied.
  final String? replyMessageUsername;

  /// The name of the user the comment is replied.
  final String? replyMessageAttachmentUrl;

  /// The replied message. Local only.
  final Message? repliedMessage;

  /// The post that was shared in the message.
  final PostBlock? sharedPost;

  /// The identifier of the shared post in the message.
  final String? _sharedPostId;

  String? get sharedPostId => _sharedPostId ?? sharedPost?.id;

  /// The date time when the message was created.
  final DateTime createdAt;

  /// The date time when the message was updated.
  final DateTime updatedAt;

  /// Whether the message is read.
  final bool isRead;

  /// Whether the message is deleted.
  final bool isDeleted;

  /// Whether the message is edited.
  final bool isEdited;

  /// The list of attachments.
  final List<Attachment> attachments;

  @override
  List<Object?> get props => [
        id,
        sender,
        type,
        message,
        createdAt,
        updatedAt,
        isRead,
        isDeleted,
        isEdited,
        attachments,
        replyMessageId,
        replyMessageUsername,
        repliedMessage,
        replyMessageAttachmentUrl,
        sharedPost,
        sharedPostId,
      ];

  static Message empty = Message();

  factory Message.fromRow(Map<String, dynamic> row) {
    return Message(
      id: row['id'] as String,
      sender: PostAuthor.confirmed(
        id: row['from_id'] as String,
        avatarUrl: row['avatar_url'] as String,
        username: row['username'] as String,
      ),
      type: (row['type'] as String).toMessageType ?? MessageType.text,
      message: row['message'] as String,
      replyMessageId: row['reply_message_id'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      isRead: (row['is_read'] as int).isTrue,
      isDeleted: (row['is_deleted'] as int).isTrue,
      isEdited: (row['is_edited'] as int).isTrue,
      attachments:
          row['attachment_id'] == null ? const [] : [Attachment.fromRow(row)],
      replyMessageUsername: row['reply_message_username'] as String?,
      repliedMessage: row['replied_message_message'] == null
          ? null
          : Message.fromReply(row),
      replyMessageAttachmentUrl: row['reply_message_attachment_url'] as String?,
      sharedPostId: row['shared_post_id'] as String?,
      sharedPost:
          row['shared_post_id'] == null ? null : PostSmallBlock.fromShared(row),
    );
  }

  factory Message.fromReply(Map<String, dynamic> reply) => Message(
        message: reply['replied_message_message'] as String,
        replyMessageUsername: reply['reply_message_username'] as String?,
        replyMessageAttachmentUrl:
            reply['reply_message_attachment_url'] as String?,
      );

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      sender: PostAuthor.fromJson(json['sender'] as Map<String, dynamic>),
      type: (json['type'] as String).toMessageType ?? MessageType.text,
      message: json['message'] as String,
      replyMessageId: json['reply_message_id'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
      isRead: json['is_read'] as bool,
      isDeleted: json['is_deleted'] as bool,
      isEdited: json['is_edited'] as bool,
      replyMessageUsername: json['reply_message_username'] as String?,
      attachments:
          json['attachments'] == null || (json['attachments'] as List).isEmpty
              ? (json['attachments'] as List)
                  .map((e) => Attachment.fromMap(e as Map<String, dynamic>))
                  .toList()
              : const [],
      repliedMessage: json['replied_message'] == null
          ? null
          : Message.fromReply(json['replied_message'] as Map<String, dynamic>),
      replyMessageAttachmentUrl:
          json['reply_message_attachment_url'] as String?,
      sharedPostId: json['shared_post_id'] as String?,
      sharedPost: json['shared_post_id'] == null
          ? null
          : PostSmallBlock.fromShared(json),
    );
  }

  Message copyWith({
    String? id,
    PostAuthor? sender,
    MessageType? type,
    String? message,
    String? replyMessageId,
    Message? repliedMessage,
    String? sharedPostId,
    PostBlock? sharedPost,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRead,
    bool? isDeleted,
    bool? isEdited,
    List<Attachment>? attachments,
    String? replyMessageUsername,
    String? replyMessageAttachmentUrl,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      message: message ?? this.message,
      replyMessageId: replyMessageId ?? this.replyMessageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      attachments: attachments ?? this.attachments,
      replyMessageUsername: replyMessageUsername ?? this.replyMessageUsername,
      replyMessageAttachmentUrl:
          replyMessageAttachmentUrl ?? this.replyMessageAttachmentUrl,
      repliedMessage: repliedMessage ?? this.repliedMessage,
      sharedPost: sharedPost ?? this.sharedPost,
      sharedPostId: sharedPostId ?? this.sharedPostId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sender': sender?.toJson(),
      'type': type.value,
      'message': message,
      'reply_message_id': replyMessageId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_read': isRead,
      'is_deleted': isDeleted,
      'is_edited': isEdited,
      'attachments': attachments.map((x) => x.toMap()).toList(),
      'replied_message': repliedMessage?.toRepliedMessage(),
      'reply_message_username': replyMessageUsername,
      'reply_message_attachment_url': replyMessageAttachmentUrl,
      'shared_post_id': sharedPostId,
      'shared_post': sharedPost?.toJson(),
    };
  }

  Map<String, dynamic> toRepliedMessage() => <String, dynamic>{
        'replied_message_message': message,
        'replied_message_shared_post_id': sharedPostId,
      };
}

extension MessageTypeFromString on String {
  MessageType? get toMessageType {
    for (final type in MessageType.values) {
      if (type.value == this) {
        return type;
      }
    }
    return null;
  }
}
