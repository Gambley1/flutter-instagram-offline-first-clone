import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

sealed class _Repository {
  const _Repository(this._powerSyncRepository);

  final PowerSyncRepository _powerSyncRepository;
}

/// User base repository.
abstract class UserBaseRepository {
  /// The currently authenticated user id.
  String? get currentUserId;

  /// Checks whether the user exists by the provided id.
  Future<bool> isUserExists({required String id});

  /// Updates current user p with provided data.
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
  });

  /// Subscribe to user by provided [followToId]. [followerId] is the id
  /// of currently authenticated user.
  Future<void> follow({
    required String followerId,
    required String followToId,
  });

  /// Check if the user identified by [subscriberId] is subscribed to
  /// the user identified by [userId].
  Future<bool> isFollowed({
    required String subscriberId,
    required String userId,
  });

  /// Returns realtime stream of subscription status of the user identified by
  /// [followerId] to the user identified by [userId].
  Stream<bool> followingStatus({
    required String followerId,
    required String userId,
  });

  /// Returns subscribers count of the user identified by [userId].
  Stream<int> followersCountOf({required String userId});

  /// Returns count of subscriptions of the user identified by [userId].
  Stream<int> followingsCountOf({required String userId});

  /// Returns a list of Profiles of subscribers of the user identified by
  /// [userId].
  Future<List<User>> getFollowers({required String userId});

  /// Returns a list of Profiles of subscriptions of the user identified by
  /// [userId].
  Future<List<User>> getFollowings({required String userId});

  Future<List<User>> searchUsers({
    required String userId,
    required int limit,
    required int offset,
    required String? query,
  });
}

/// Abstract base class for a posts repository.
abstract class PostsBaseRepository {
  /// Reads the associated post from the database by the [id].
  Future<Post?> getPostBy({required String id});

  /// Likes the post as user by [userId] by provided either post or comment
  /// [id].
  Future<void> like({
    required String id,
    required String userId,
    bool post = true,
  });

  /// Returns a real-time stream of likes count of post by provided [id].
  Stream<int> likesOf({
    required String id,
    bool post = true,
  });

  /// Returns a real-time stream of whether the post by [id] is liked by user
  /// identified by [userId].
  Stream<bool> isLiked({
    required String id,
    required String userId,
    bool post = true,
  });

  /// Returns the page of posts with provided [offset] and [limit].
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
  });

  /// Create a new post with provided details.
  Future<Post> createPost({
    required String id,
    required String userId,
    required String caption,
    required String type,
    required String mediaUrl,
    required String imagesUrl,
  });

  /// Deletes the post with provided [id].
  Future<void> deletePost({required String id});

  /// Updates the post with provided [id] and optional parameters to update.
  Future<void> updatePost({required String id});

  /// Returns the stream of real-time posts of the user identified by
  /// [currentUserId].
  ///
  /// There is an optional parameters [userId] which if provided also checks
  /// whether the currently authenticated user by [currentUserId] is subscribed
  /// to the user identified by [userId].
  Stream<List<Post>> postsOf({
    required String currentUserId,
    String? userId,
  });

  /// Returns a stream of amount of posts of the user identified by [userId].
  Stream<int> postsAmountOf({required String userId});

  /// Returns a stream of amount of comments of the post identified by [postId].
  Stream<int> commentsAmountOf({required String postId});

  /// Returns a stream of comments of the post identified by [postId].
  Stream<List<Comment>> commentsOf({required String postId});

  /// Returns a stream of replied comments of the comment identified by
  /// [commentId].
  Stream<List<Comment>> repliedCommentsOf({required String commentId});

  /// Created a comment with provided details.
  Future<void> createComment({
    required String content,
    required String postId,
    required String userId,
    String? repliedToCommentId,
  });

  /// Delete the comment by associated [id].
  Future<void> deleteComment({required String id});

  /// Shares the post with the user identified by [recipientUserId].
  Future<void> sharePost({
    required String id,
    required String senderUserId,
    required Message message,
    String? recipientUserId,
  });
}

abstract class ChatsBaseRepository {
  Stream<List<ChatInbox>> chatsOf({required String userId});

  Stream<List<Message>> messagesOf({required String chatId});

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required Message message,
  });

  Future<void> deleteMessage({required String messageId});

  Future<void> deleteChat({required String chatId, required String userId});

  Future<void> createChat({
    required String userId,
    required String participantId,
  });

  Future<void> readMessage({
    required String messageId,
  });

  Future<void> editMessage({
    required Message oldMessage,
    required Message newMessage,
  });
}

/// Abstract base class for database client that extends `Repository` and
/// implements [UserBaseRepository] and [PostsBaseRepository].
/// Contains a constructor to initialize the `powerSyncRepository`.
abstract class Client extends _Repository
    implements UserBaseRepository, PostsBaseRepository, ChatsBaseRepository {
  /// {@macro client}
  const Client(super.powerSyncRepository);
}

/// {@template database_client}
/// A package that manages application database workflow.
/// {@endtemplate}
class DatabaseClient extends Client {
  /// {@macro database_client}
  const DatabaseClient(super.powerSyncRepository);

  @override
  String? get currentUserId =>
      Supabase.instance.client.auth.currentSession?.user.id;

  @override
  Future<bool> isUserExists({required String id}) async {
    final user = await _powerSyncRepository.db().execute(
      '''
SELECT * FROM profiles WHERE id = ?
''',
      [id],
    );
    if (user.isEmpty) return false;
    return true;
  }

  @override
  Future<Post> createPost({
    required String id,
    required String userId,
    required String caption,
    required String type,
    required String mediaUrl,
    required String imagesUrl,
  }) async {
    final result = await _powerSyncRepository.db().execute(
      '''
    INSERT INTO posts(id, user_id, caption, type, media_url, created_at, images_url)
    VALUES(?, ?, ?, ?, ?, datetime(), ?)
    RETURNING *
    ''',
      [
        id,
        userId,
        caption,
        type,
        mediaUrl,
        imagesUrl,
      ],
    );
    return Post.fromRow(
      result.first,
      author: result.first['user_id'] as String,
    );
  }

  @override
  Stream<int> postsAmountOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        '''
    SELECT COUNT(*) as posts_count FROM posts where user_id = ?
    ''',
        parameters: [userId],
      ).map(
        (event) => event.map((element) => element['posts_count']).first as int,
      );

  @override
  Stream<List<Post>> postsOf({required String currentUserId, String? userId}) {
    if (userId == null) {
      return _powerSyncRepository.db().watch(
        '''
SELECT
  posts.*,
  p.avatar_url as avatar_url,
  p.username as username
FROM
  posts
  left join profiles p on posts.user_id = p.id 
WHERE user_id = ?1
ORDER BY created_at DESC
      ''',
        parameters: [currentUserId],
      ).map(
        (event) => event
            .map(
              (row) => Post.fromRow(
                row,
                author: currentUserId,
              ),
            )
            .toList(growable: false),
      );
    }
    return _powerSyncRepository.db().watch(
      '''
SELECT
  posts.*,
  p.avatar_url as avatar_url,
  p.username as username
FROM
  posts
  left join profiles p on posts.user_id = p.id 
WHERE user_id = ?
ORDER BY created_at DESC
      ''',
      parameters: [userId],
    ).asyncMap((event) async {
      final posts = <Post>[];

      for (final row in event) {
        final isSubscribed = await isFollowed(
          subscriberId: currentUserId,
          userId: row['user_id'] as String,
        );
        final post = Post.fromRow(
          row,
          author: currentUserId,
          subscribed: isSubscribed.toInt,
        );
        posts.add(post);
      }
      return posts;
    });
  }

  @override
  Future<void> deletePost({required String id}) =>
      _powerSyncRepository.db().execute('DELETE FROM posts WHERE id = ?', [id]);

  @override
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
  }) async {
    final result = await _powerSyncRepository.db().execute(
      '''
SELECT
  posts.*,
  p.avatar_url as avatar_url,
  p.username as username
FROM
  posts
  inner join profiles p on posts.user_id = p.id 
ORDER BY created_at DESC LIMIT ?1 OFFSET ?2
    ''',
      [limit, offset],
    );

    final posts = <Post>[];

    for (final row in result) {
      final isSubscribed = await isFollowed(
        subscriberId: currentUserId!,
        userId: row['user_id'] as String,
      );
      final post = Post.fromRow(
        row,
        author: currentUserId!,
        subscribed: isSubscribed.toInt,
      );
      posts.add(post);
    }
    return posts;
  }

  @override
  Future<void> updatePost({required String id}) =>
      _powerSyncRepository.db().execute(
        'UPDATE posts WHERE id = ?',
        [id],
      );

  @override
  Stream<int> likesOf({required String id, bool post = true}) {
    final statement = post ? 'post_id' : 'comment_id';
    return _powerSyncRepository.db().watch(
      'SELECT COUNT(*) AS likes_count FROM likes '
      'WHERE $statement = ? AND $statement IS NOT NULL',
      parameters: [id],
    ).map(
      (event) => event.map((element) => element['likes_count']).first as int,
    );
  }

  @override
  Stream<bool> isLiked({
    required String id,
    required String userId,
    bool post = true,
  }) {
    final statement = post ? 'post_id' : 'comment_id';
    return _powerSyncRepository.db().watch(
      '''
      SELECT EXISTS (
        SELECT 1 
        FROM likes
        WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL
      )
''',
      parameters: [userId, id],
    ).map((event) => (event.first.values.first! as int).isTrue);
  }

  @override
  Future<Post?> getPostBy({required String id}) async {
    final post = await _powerSyncRepository.db().execute(
      '''
SELECT
  posts.*,
  p.avatar_url as avatar_url,
  p.username as username
FROM
  posts
  join profiles p on posts.user_id = p.id 
WHERE posts.id = ?
  ''',
      [id],
    );
    if (post.isEmpty) return null;
    return Post.fromRow(post.first, author: currentUserId!);
  }

  @override
  Future<void> like({
    required String id,
    required String userId,
    bool post = true,
  }) async {
    final statement = post ? 'post_id' : 'comment_id';
    final exists = await _powerSyncRepository.db().execute(
      'SELECT 1 FROM likes '
      'WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL',
      [userId, id],
    );
    if (exists.isEmpty) {
      await _powerSyncRepository.db().execute(
        '''
          INSERT INTO likes(user_id, $statement, id)
            VALUES(?, ?, uuid())
      ''',
        [userId, id],
      );
      return;
    }
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM likes 
          WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL
      ''',
      [userId, id],
    );
  }

  @override
  Stream<int> followersCountOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        'SELECT COUNT(*) AS subscription_count FROM subscriptions '
        'WHERE subscribed_to_id = ?',
        parameters: [userId],
      ).map(
        (event) =>
            event.map((element) => element['subscription_count']).first as int,
      );

  @override
  Future<void> follow({
    required String followerId,
    required String followToId,
  }) async {
    final exists =
        await isFollowed(subscriberId: followerId, userId: followToId);
    if (!exists) {
      await _powerSyncRepository.db().execute(
        '''
          INSERT INTO subscriptions(id, subscriber_id, subscribed_to_id)
            VALUES(uuid(), ?, ?)
      ''',
        [followerId, followToId],
      );
      return;
    }
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [followerId, followToId],
    );
  }

  @override
  Stream<int> followingsCountOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        'SELECT COUNT(*) AS subscription_count FROM subscriptions '
        'WHERE subscriber_id = ?',
        parameters: [userId],
      ).map(
        (event) =>
            event.map((element) => element['subscription_count']).first as int,
      );

  @override
  Future<List<User>> getFollowers({required String userId}) async {
    final subscribersId = await _powerSyncRepository.db().getAll(
      'SELECT subscriber_id FROM subscriptions WHERE subscribed_to_id = ? ',
      [userId],
    );
    if (subscribersId.isEmpty) return [];

    final subscribers = <User>[];
    for (final subscriberId in subscribersId) {
      final result = await _powerSyncRepository.db().execute(
        'SELECT * FROM profiles WHERE id = ?',
        [subscriberId['subscriber_id']],
      );
      if (result.isEmpty) continue;
      final subscriber = User.fromRow(result.first);
      subscribers.add(subscriber);
    }
    return subscribers;
  }

  @override
  Future<List<User>> getFollowings({required String userId}) async {
    final subscribedToUsersId = await _powerSyncRepository.db().getAll(
      'SELECT subscribed_to_id FROM subscriptions WHERE subscriber_id = ? ',
      [userId],
    );
    if (subscribedToUsersId.isEmpty) return [];

    final subscribedToUsers = <User>[];
    for (final subscribedToUserId in subscribedToUsersId) {
      final result = await _powerSyncRepository.db().execute(
        'SELECT * FROM profiles WHERE id = ?',
        [subscribedToUserId['subscribed_to_id']],
      );
      if (result.isEmpty) continue;
      final subscribedToUser = User.fromRow(result.first);
      subscribedToUsers.add(subscribedToUser);
    }
    return subscribedToUsers;
  }

  @override
  Future<bool> isFollowed({
    required String subscriberId,
    required String userId,
  }) async {
    final result = await _powerSyncRepository.db().execute(
      '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
      [subscriberId, userId],
    );
    return result.isNotEmpty;
  }

  @override
  Stream<bool> followingStatus({
    required String followerId,
    required String userId,
  }) =>
      _powerSyncRepository.db().watch(
        '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
        parameters: [followerId, userId],
      ).map((event) => event.isNotEmpty);

  @override
  Stream<int> commentsAmountOf({required String postId}) =>
      _powerSyncRepository.db().watch(
        '''
SELECT COUNT(*) AS comments_count FROM comments
WHERE post_id = ? 
''',
        parameters: [postId],
      ).map(
        (result) => result.map((row) => row['comments_count']).first as int,
      );

  @override
  Stream<List<Comment>> commentsOf({required String postId}) =>
      _powerSyncRepository.db().watch(
        '''
SELECT 
  c1.*,
  p.avatar_url as avatar_url,
  p.username as username,
  COUNT(c2.id) AS replies
FROM 
  comments c1
  INNER JOIN
    profiles p ON p.id = c1.user_id
  LEFT JOIN
    comments c2 ON c1.id = c2.replied_to_comment_id
WHERE
  c1.post_id = ? AND c1.replied_to_comment_id IS NULL
GROUP BY
    c1.id, p.avatar_url, p.username
ORDER BY created_at ASC
''',
        parameters: [postId],
      ).map(
        (result) => result.map(Comment.fromRow).toList(growable: false),
      );

  @override
  Future<void> createComment({
    required String postId,
    required String userId,
    required String content,
    String? repliedToCommentId,
  }) =>
      _powerSyncRepository.db().execute(
        '''
INSERT INTO
  comments(id, post_id, user_id, content, created_at, replied_to_comment_id)
VALUES(uuid(), ?, ?, ?, ?, ?)
''',
        [
          postId,
          userId,
          content,
          DateTime.timestamp().toIso8601String(),
          repliedToCommentId,
        ],
      );

  @override
  Future<void> deleteComment({required String id}) =>
      _powerSyncRepository.db().execute(
        '''
DELETE FROM comments
WHERE id = ?
''',
        [id],
      );

  @override
  Future<void> sharePost({
    required String id,
    required String senderUserId,
    required Message message,
    String? recipientUserId,
  }) async {
    final exists = await _powerSyncRepository.db().execute(
      '''
SELECT 1 FROM posts WHERE id = ?
''',
      [id],
    );
    if (exists.isEmpty) return;
    if (recipientUserId == null) return;
    final conversation = await _powerSyncRepository.db().execute(
      '''
SELECT conversation_id
  FROM Participants
WHERE user_id = ?
  AND conversation_id IN (
      SELECT conversation_id
      FROM Participants
      WHERE user_id = ?
    );
''',
      [senderUserId, recipientUserId],
    );
    if (conversation.isNotEmpty) {
      final chatId = conversation.first['conversation_id'] as String;
      await sendMessage(
        chatId: chatId,
        senderId: senderUserId,
        message: message.copyWith(sharedPostId: id),
      );
      return;
    }
    final newChatId = UidGenerator.v4();
    final createdConversation = _powerSyncRepository.db().execute(
      '''
insert into
  conversations (id, type, name, created_at, updated_at)
values
  (?, ?, '', ?, ?)
''',
      [newChatId, ChatType.oneOnOne.value, JiffyX.now(), JiffyX.now()],
    );
    final addParticipant1 = _powerSyncRepository.db().execute(
      '''
insert into
  participants (id, user_id, conversation_id)
  values
  (?, ?, ?)
  ''',
      [UidGenerator.v4(), senderUserId, newChatId],
    );
    final addParticipant2 = _powerSyncRepository.db().execute(
      '''
insert into
  participants (id, user_id, conversation_id)
  values
  (?, ?, ?)
  ''',
      [UidGenerator.v4(), recipientUserId, newChatId],
    );
    await createdConversation
        .whenComplete(() => Future.wait([addParticipant1, addParticipant2]));

    await sendMessage(
      chatId: newChatId,
      senderId: senderUserId,
      message: message.copyWith(sharedPostId: id),
    );
  }

  @override
  Stream<List<Comment>> repliedCommentsOf({required String commentId}) =>
      _powerSyncRepository.db().watch(
        '''
SELECT 
  c1.*,
  p.avatar_url as avatar_url,
  p.username as username
FROM 
  comments c1
  INNER JOIN
    profiles p ON p.id = c1.user_id
WHERE
  c1.replied_to_comment_id = ? 
GROUP BY
    c1.id, p.avatar_url, p.username
ORDER BY created_at ASC
''',
        parameters: [commentId],
      ).map(
        (result) => result.map(Comment.fromRow).toList(),
      );

  @override
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
  }) =>
      _powerSyncRepository.updateUser({
        if (fullName != null) 'fulll_name': fullName,
        if (email != null) 'email': email,
        if (username != null) 'username': username,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (pushToken != null) 'push_token': pushToken,
      });

  @override
  Stream<List<ChatInbox>> chatsOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        '''
select
  c.id,
  c.type,
  c.name,
  p2.id as participant_id,
  p2.full_name as participant_name,
  p2.email as participant_email,
  p2.username as participant_username,
  p2.avatar_url as participant_avatar_url,
  p2.push_token as participant_push_token
from
  conversations c
  join participants pt on c.id = pt.conversation_id
  join profiles p on pt.user_id = p.id
  join participants pt2 on c.id = pt2.conversation_id
  join profiles p2 on pt2.user_id = p2.id
where
  pt.user_id = ?1
  and pt2.user_id != ?1
''',
        parameters: [userId],
      ).map((event) => event.map(ChatInbox.fromRow).toList(growable: false));

  @override
  Stream<List<Message>> messagesOf({required String chatId}) =>
      _powerSyncRepository.db().watch(
        '''
SELECT
  m.*,
  m_sender.full_name as full_name,
  m_sender.username as username,
  m_sender.avatar_url as avatar_url,
  a.id as attachment_id,
  a.title as attachment_title,
  a.text as attachment_text,
  a.title_link as attachment_title_link,
  a.image_url as attachment_image_url,
  a.thumb_url as attachment_thumb_url,
  a.author_name as attachment_author_name,
  a.author_link as attachment_author_link,
  a.asset_url as attachment_asset_url,
  a.og_scrape_url as attachment_og_scrape_url,
  a.type as attachment_type,
  r.message as replied_message_message,
  p.caption as shared_post_caption,
  p.created_at as shared_post_published_at,
  p.media_url as shared_post_image_url,
  p.images_url as shared_post_images_url,
  p_author.id as shared_post_author_id,
  p_author.username as shared_post_author_username,
  p_author.avatar_url as shared_post_author_avatar_url
FROm
  messages m
  left join attachments a on m.id = a.message_id
  left join messages r on m.reply_message_id = r.id
  left join posts p on m.shared_post_id = p.id
  join profiles m_sender on m.from_id = m_sender.id
  left join profiles p_author on p.user_id = p_author.id
where
  m.conversation_id = ?   
order by created_at asc
''',
        parameters: [chatId],
      ).map((event) => event.map(Message.fromRow).toList(growable: false));

  @override
  Future<void> createChat({
    required String userId,
    required String participantId,
  }) async {
    final conversationId = UidGenerator.v4();
    final createdConversation = _powerSyncRepository.db().execute(
      '''
insert into
  conversations (id, type, name, created_at, updated_at)
values
  (?, ?, '', ?, ?)
''',
      [conversationId, ChatType.oneOnOne.value, JiffyX.now(), JiffyX.now()],
    );
    final addParticipant1 = _powerSyncRepository.db().execute(
      '''
insert into
  participants (id, user_id, conversation_id)
  values
  (?, ?, ?)
  ''',
      [UidGenerator.v4(), userId, conversationId],
    );
    final addParticipant2 = _powerSyncRepository.db().execute(
      '''
insert into
  participants (id, user_id, conversation_id)
  values
  (?, ?, ?)
  ''',
      [UidGenerator.v4(), participantId, conversationId],
    );
    await createdConversation
        .whenComplete(() => Future.wait([addParticipant1, addParticipant2]));
  }

  @override
  Future<void> deleteChat({
    required String chatId,
    required String userId,
  }) async {
//     final participants = (await _powerSyncRepository.db().get(
//       '''
// select
//   count(*) as participants_count
// from
//   participants
// where conversation_id = ?
// ''',
//       [chatId],
//     ))['participants_count'] as int;
//     if (participants >= 1) {
//       final isParticipantInConversation = await _powerSyncRepository.db().get(
//         '''
// select
//   *
// from
//   participants
// where
//   user_id = ?
//   and conversation_id = ?
//   ''',
//         [userId, chatId],
//       );
//       if (isParticipantInConversation.isEmpty) return;
//       await _powerSyncRepository.db().execute(
//         '''
// delete from participants
// where
//   user_id = ?
//   and conversation_id = ?
// ''',
//         [userId, chatId],
//       );
//       return;
//     }
    await _powerSyncRepository.db().execute(
      '''
delete from conversations
where
  id = ?
''',
      [chatId],
    );
  }

  @override
  Future<void> deleteMessage({required String messageId}) =>
      _powerSyncRepository.db().execute(
        '''
delete from messages
where
  id = ?
''',
        [messageId],
      );

  @override
  Future<void> readMessage({
    required String messageId,
  }) async {
    await _powerSyncRepository.db().execute(
      '''
UPDATE messages
SET
  is_read = 1
WHERE
  id = ?
''',
      [messageId],
    );
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required Message message,
  }) =>
      _powerSyncRepository.db().writeTransaction((sqlContext) async {
        await sqlContext.execute(
          '''
insert into
  messages (
    id, conversation_id, from_id, type, message, reply_message_id, created_at, 
    updated_at, is_read, is_deleted, is_edited, reply_message_username,
    reply_message_attachment_url, shared_post_id
    )
values
  (?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, ?, ?, ?)
''',
          [
            message.id,
            chatId,
            senderId,
            message.type.value,
            message.message,
            message.replyMessageId,
            DateTime.now().toIso8601String(),
            DateTime.now().toIso8601String(),
            message.replyMessageUsername,
            message.replyMessageAttachmentUrl,
            message.sharedPostId,
          ],
        );

        await sqlContext.executeBatch(
          '''
insert into
  attachments (
    id, message_id, title, text, title_link, image_url,
    thumb_url, author_name, author_link, asset_url, og_scrape_url, type
  )
values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
          message.attachments
              .map(
                (a) => [
                  a.id,
                  message.id,
                  a.title,
                  a.text,
                  a.titleLink,
                  a.imageUrl,
                  a.thumbUrl,
                  a.authorName,
                  a.authorLink,
                  a.assetUrl,
                  a.ogScrapeUrl,
                  a.type,
                ],
              )
              .toList(),
        );
      });

  @override
  Future<void> editMessage({
    required Message oldMessage,
    required Message newMessage,
  }) async {
    late final newMessageHasAttachments = newMessage.attachments.isNotEmpty;
    late final oldMessageHasAttachments = oldMessage.attachments.isNotEmpty;
    late final updateOldMessageAttachments =
        newMessageHasAttachments && oldMessageHasAttachments;
    late final insertNewMessageAttachments =
        newMessageHasAttachments && !oldMessageHasAttachments;

    await _powerSyncRepository.db().execute(
      '''
update messages
set
  message = ?1,
  updated_at = ?2
where
  id = ?3
''',
      [
        newMessage.message,
        DateTime.timestamp().toIso8601String(),
        newMessage.id,
      ],
    );
    if (!newMessageHasAttachments && oldMessageHasAttachments) {
      await _powerSyncRepository.db().execute(
        '''
delete from attachments
where message_id = ?
        ''',
        [newMessage.id],
      );
      return;
    }
    if (updateOldMessageAttachments) {
      final oldAttachmentId = oldMessage.attachments.first.id;
      await _powerSyncRepository.db().executeBatch(
        '''
update attachments
set
  title = ?,
  text = ?,
  title_link = ?,
  image_url = ?,
  thumb_url = ?,
  author_name = ?,
  author_link = ?,
  asset_url = ?,
  og_scrape_url = ?
where
  id = ?
  and message_id = ?
''',
        newMessage.attachments
            .map(
              (a) => [
                a.title,
                a.text,
                a.titleLink,
                a.imageUrl,
                a.thumbUrl,
                a.authorName,
                a.authorLink,
                a.assetUrl,
                a.ogScrapeUrl,
                oldAttachmentId,
                oldMessage.id,
              ],
            )
            .toList(),
      );
      return;
    }
    if (insertNewMessageAttachments) {
      await _powerSyncRepository.db().executeBatch(
        '''
insert into
  attachments (
    id, message_id, title, text, title_link, image_url,
    thumb_url, author_name, author_link, asset_url, og_scrape_url, type
  )
values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
        newMessage.attachments
            .map(
              (a) => [
                a.id,
                newMessage.id,
                a.title,
                a.text,
                a.titleLink,
                a.imageUrl,
                a.thumbUrl,
                a.authorName,
                a.authorLink,
                a.assetUrl,
                a.ogScrapeUrl,
                a.type,
              ],
            )
            .toList(),
      );
    }
  }

  @override
  Future<List<User>> searchUsers({
    required String userId,
    required int limit,
    required int offset,
    required String? query,
  }) async {
    final result = await _powerSyncRepository.db().getAll(
      '''
SELECT *
  FROM profiles
WHERE id != ?1 
  AND username LIKE '%$query%'
  OR full_name LIKE '%$query%'
LIMIT ?2 OFFSET ?3
''',
      [userId, limit, offset],
    );

    final users = result.map(User.fromRow).toList();
    return users;
  }
}
