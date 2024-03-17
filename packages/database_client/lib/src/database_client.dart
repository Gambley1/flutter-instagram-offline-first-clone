import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:env/env.dart';
import 'package:flutter/foundation.dart';
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

  /// Broadcasts the user profile identified by [id].
  Stream<User> profile({required String id});

  /// Checks whether the user exists by the provided id.
  Future<bool> isUserExists({required String id});

  /// Updates currently authenticated database user's metadata.
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
  });

  /// Sends a reset password email to the provided [email].
  Future<void> resetPasswordForEmail({
    required String email,
    String? redirectTo,
  });

  /// Resets user password and updates user's metadata.
  /// If user successfully verifies OTP [token] he automatically authenticates
  /// into account by provided [email].
  Future<void> resetPassword({
    required String token,
    required String email,
    required String newPassword,
  });

  /// Follows to the user by provided [followToId]. [followerId] is the id
  /// of currently authenticated user.
  Future<void> follow({
    required String followToId,
    String? followerId,
  });

  /// Unfollows from user profile, identified by [unfollowId].
  Future<void> unfollow({required String unfollowId, String? unfollowerId});

  /// Removes follower from followers of current users.
  Future<void> removeFollower({required String id});

  /// Check if the user identified by [followerId] is followed to
  /// the user identified by [userId].
  Future<bool> isFollowed({
    required String followerId,
    required String userId,
  });

  /// Returns realtime stream of followings status of the user identified by
  /// [followerId] to the user identified by [userId].
  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  });

  /// Returns followings count of the user identified by [userId].
  Stream<int> followersCountOf({required String userId});

  /// Returns count of followings of the user identified by [userId].
  Stream<int> followingsCountOf({required String userId});

  /// Returns a list of followers of the user identified by [userId].
  Future<List<User>> getFollowers({required String userId});

  /// Returns a list of followings of the user identified by [userId].
  Future<List<User>> getFollowings({required String userId});

  /// Broadcasts a list of followers of the user identified by [userId].
  Stream<List<User>> streamFollowers({required String userId});

  /// Broadcasts a list of followings of the user identified by [userId].
  Stream<List<User>> streamFollowings({required String userId});

  /// Looks up into a database a returns users associated with the provided
  /// [query].
  Future<List<User>> searchUsers({
    required String userId,
    required int limit,
    required int offset,
    required String? query,
    String? excludeUserIds,
  });
}

/// Abstract base class for a posts repository.
abstract class PostsBaseRepository {
  /// Reads the associated post from the database by the [id].
  Future<Post?> getPostBy({required String id});

  /// Fetches the profiles of users who liked post, idenitifed by [postId].
  Future<List<User>> getPostLikers({
    required String postId,
    int limit = 30,
    int offset = 0,
  });

  /// Fetches the profiles of users who liked the post, identified by [postId]
  /// and who are in followings of the user identified by current user `id`.
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  });

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
    bool onlyReels = false,
  });

  /// Uploads the post [Media] to the server.
  Future<void> uploadMedia({
    required String id,
    required String ownerId,
    required String url,
    required String type,
    required String blurHash,
    required String? firstFrame,
  });

  /// Create a new post with provided details.
  Future<Post?> createPost({
    required String id,
    required String userId,
    required String caption,
    required String media,
  });

  /// Deletes the post with provided [id].
  /// Returns the optional `id` of the deleted post.
  Future<String?> deletePost({required String id});

  /// Updates the post with provided [id] and optional parameters to update.
  Future<Post?> updatePost({required String id, String? caption});

  /// Returns the stream of real-time posts of the current user.
  Stream<List<Post>> postsOf({String? userId});

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

  /// Shares the post with the user identified by [receiver].
  Future<void> sharePost({
    required String id,
    required User sender,
    required User receiver,
    required Message sharedPostMessage,
    Message? message,
    PostAuthor? postAuthor,
  });
}

/// Abstract base class for a chats repository.
abstract class ChatsBaseRepository {
  /// Returns a stream of real-time chats of the user identified by [userId].
  Stream<List<ChatInbox>> chatsOf({required String userId});

  /// Returns a chat conversation with provided [chatId] and [userId].
  Future<ChatInbox> getChat({required String chatId, required String userId});

  /// Returns a stream of real-time messages of the chat identified by [chatId].
  Stream<List<Message>> messagesOf({required String chatId});

  /// Creates and send message with provided data. After sending the message
  /// the notification is sent to the user, identified by [receiver]'s `id`.
  Future<void> sendMessage({
    required String chatId,
    required User sender,
    required User receiver,
    required Message message,
    PostAuthor? postAuthor,
  });

  /// Deletes the message with provided [messageId].
  Future<void> deleteMessage({required String messageId});

  /// Deletes the chat with provided [chatId] and participant from the chat,
  /// identified by [userId].
  Future<void> deleteChat({required String chatId, required String userId});

  /// Creates a new chat with provided [userId] and [participantId].
  Future<void> createChat({
    required String userId,
    required String participantId,
  });

  /// Marks the message as read by [messageId].
  Future<void> readMessage({
    required String messageId,
  });

  /// Edits the message with provided [oldMessage] and [newMessage].
  Future<void> editMessage({
    required Message oldMessage,
    required Message newMessage,
  });
}

/// The abstract base class for a stories repository.
abstract class StoriesBaseRepository {
  /// {@macro stories_base_repository}
  const StoriesBaseRepository();

  /// Returns the [Story] identified by [id].
  Future<Story> getStory({required String id});

  /// Broadcasts the stream of the stories from the database.
  Stream<List<Story>> getStories({
    required String userId,
    bool includeAuthor = true,
  });

  /// Creates the [Story] with the provided data.
  Future<void> createStory({
    required User author,
    required StoryContentType contentType,
    required String contentUrl,
    String? id,
    int? duration,
  });

  /// Deletes the [Story] identified by [id].
  Future<void> deleteStory({required String id});

  /// Uploads the story media into the Supabase storage.
  Future<String> uploadStoryMedia({
    required String storyId,
    required File imageFile,
    required Uint8List imageBytes,
  });
}

/// Abstract base class for database client that extends `Repository` and
/// implements [UserBaseRepository] and [PostsBaseRepository].
/// Contains a constructor to initialize the `powerSyncRepository`.
abstract class Client extends _Repository
    implements
        UserBaseRepository,
        PostsBaseRepository,
        ChatsBaseRepository,
        StoriesBaseRepository {
  /// {@macro client}
  const Client(super.powerSyncRepository);
}

/// {@template database_client}
/// A package that manages application database workflow.
/// {@endtemplate}
class DatabaseClient extends Client {
  /// {@macro database_client}
  DatabaseClient(super.powerSyncRepository);

  @override
  String? get currentUserId =>
      _powerSyncRepository.supabase.auth.currentSession?.user.id;

  @override
  Stream<User> profile({required String id}) => _powerSyncRepository.db().watch(
        'SELECT * FROM profiles WHERE id = ?',
        parameters: [id],
      ).map(
        (event) => event.isEmpty ? User.anonymous : User.fromJson(event.first),
      );

  @override
  Future<bool> isUserExists({required String id}) async {
    final user = await _powerSyncRepository.db().execute(
      '''
SELECT id FROM profiles WHERE id = ?
''',
      [id],
    );
    if (user.isEmpty) return false;
    return true;
  }

  @override
  Future<Post?> createPost({
    required String id,
    required String userId,
    required String caption,
    required String media,
  }) async {
    if (currentUserId == null) return null;
    final result = await Future.wait([
      _powerSyncRepository.db().execute(
        '''
    INSERT INTO posts(id, user_id, caption, media, created_at)
    VALUES(?, ?, ?, ?, ?)
    RETURNING *
    ''',
        [id, userId, caption, media, DateTime.timestamp().toIso8601String()],
      ),
      _powerSyncRepository.db().get(
        '''
SELECT * FROM profiles WHERE id = ?
''',
        [currentUserId],
      ),
    ]);
    if (result.isEmpty) return null;
    final row = Map<String, dynamic>.from((result.first as ResultSet).first);
    final author = User.fromJson(result.last as Row);
    return Post.fromJson(row).copyWith(author: author);
  }

  @override
  Stream<int> postsAmountOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        '''
    SELECT COUNT(*) as posts_count FROM posts where user_id = ?
    ''',
        parameters: [userId],
      ).map(
        (event) =>
            event.safeMap((element) => element['posts_count']).first as int,
      );

  @override
  Stream<List<Post>> postsOf({String? userId}) {
    if (currentUserId == null) return const Stream.empty();
    if (userId == null) {
      return _powerSyncRepository.db().watch(
        '''
SELECT
  posts.*,
  p.id as user_id,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  left join profiles p on posts.user_id = p.id 
WHERE user_id = ?1
ORDER BY created_at DESC
      ''',
        parameters: [currentUserId],
      ).map(
        (event) => event
            .safeMap((row) => Post.fromJson(Map<String, dynamic>.from(row)))
            .toList(growable: false),
      );
    }
    return _powerSyncRepository.db().watch(
      '''
SELECT
  posts.*,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  left join profiles p on posts.user_id = p.id 
WHERE user_id = ?
ORDER BY created_at DESC
      ''',
      parameters: [userId],
    ).map(
      (event) => event
          .safeMap((row) => Post.fromJson(Map<String, dynamic>.from(row)))
          .toList(growable: false),
    );
  }

  @override
  Future<String?> deletePost({required String id}) async {
    final result = await _powerSyncRepository
        .db()
        .execute('DELETE FROM posts WHERE id = ? RETURNING id', [id]);
    if (result.isEmpty) return null;
    return result.first['id'] as String;
  }

  // ignore: unused_element
  Future<List<Media>> _getPostMedia({
    required List<Map<String, dynamic>> mediaJsons,
  }) async {
    final media = <Media>[];
    for (final mediaJson in mediaJsons) {
      if (mediaJson['type'] == ImageMedia.identifier) {
        final row = await _powerSyncRepository.db().getOptional(
          '''
SELECT * FROM images WHERE id = ?
''',
          [mediaJson['id']],
        );
        if (row == null) continue;
        final imageMedia = ImageMedia.fromJson(row);
        media.add(imageMedia);
      }
      if (mediaJson['type'] == VideoMedia.identifier) {
        final row = await _powerSyncRepository.db().getOptional(
          '''
SELECT * FROM videos WHERE id = ?
''',
          [mediaJson['id']],
        );
        if (row == null) continue;
        final videoMedia = VideoMedia.fromJson(row);
        media.add(videoMedia);
      }
    }
    return media;
  }

  @override
  Future<void> uploadMedia({
    required String id,
    required String ownerId,
    required String url,
    required String type,
    required String blurHash,
    required String? firstFrame,
  }) async {
    if (type == ImageMedia.identifier) {
      await _powerSyncRepository.db().execute(
        '''
INSERT INTO images(id, owner_id, url, blur_hash)
VALUES(?1,?2,?3,?4)
ON CONFLICT (id) DO UPDATE SET url = ?3, blur_hash = ?4, owner_id = ?2
        ''',
        [id, ownerId, url, blurHash],
      );
    }
    if (type == VideoMedia.identifier) {
      await _powerSyncRepository.db().execute(
        '''
INSERT INTO videos(id, owner_id, url, first_frame, blur_hash)
VALUES(?1,?2,?3,?4,?5)
ON CONFLICT (id) DO UPDATE SET url = ?3, blur_hash = ?5, owner_id = ?2, first_frame = ?4
        ''',
        [id, ownerId, url, firstFrame, blurHash],
      );
    }
  }

  @override
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
    bool onlyReels = false,
  }) async {
//     if (onlyReels) {
//       final result = await _powerSyncRepository.db().execute(
//         '''
// SELECT
//   posts.*,
//   p.id as user_id,
//   p.avatar_url as avatar_url,
//   p.username as username
// FROM
//   posts
//   inner join profiles p on posts.user_id = p.id
// WHERE array_length(array(posts.media), 1) = 1
//   AND posts.media.type = '__video_media__'
// LIMIT ?1 OFFSET ?2
//     ''',
//         [limit, offset],
//       );

//       final posts = <Post>[];

//       for (final row in result) {
//         final json = Map<String, dynamic>.from(row);
//         final post = Post.fromJson(json);
//         posts.add(post);
//       }
//       return posts;
//     }
    final result = await _powerSyncRepository.db().execute(
      '''
SELECT
  posts.*,
  p.id as user_id,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  inner join profiles p on posts.user_id = p.id 
ORDER BY created_at DESC LIMIT ?1 OFFSET ?2
    ''',
      [limit, offset],
    );

    final posts = <Post>[];

    for (final row in result) {
      final json = Map<String, dynamic>.from(row);
      final post = Post.fromJson(json);
      posts.add(post);
    }
    return posts;
  }

  @override
  Future<Post?> updatePost({required String id, String? caption}) async {
    final row = await _powerSyncRepository.db().execute(
      '''
UPDATE posts
SET
  caption = ?2
WHERE id = ?1
RETURNING *
''',
      [id, caption],
    );
    if (row.isEmpty) return null;
    final json = Map<String, dynamic>.from(row.first);
    return Post.fromJson(json);
  }

  @override
  Stream<int> likesOf({required String id, bool post = true}) {
    final statement = post ? 'post_id' : 'comment_id';
    return _powerSyncRepository.db().watch(
      '''
SELECT COUNT(*) AS total_likes
FROM likes
WHERE $statement = ? AND $statement IS NOT NULL
''',
      parameters: [id],
    ).map((result) => result.safeMap((row) => row['total_likes']).first as int);
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
    final row = await _powerSyncRepository.db().getOptional(
      '''
SELECT
  posts.*,
  p.id as user_id,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  join profiles p on posts.user_id = p.id 
WHERE posts.id = ?
  ''',
      [id],
    );
    if (row == null) return null;
    return Post.fromJson(Map<String, dynamic>.from(row));
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
        (event) => event
            .safeMap((element) => element['subscription_count'])
            .first as int,
      );

  @override
  Future<void> follow({
    required String followToId,
    String? followerId,
  }) async {
    if (currentUserId == null) return;
    if (followToId == currentUserId) return;
    final exists = await isFollowed(
      followerId: followerId ?? currentUserId!,
      userId: followToId,
    );
    if (!exists) {
      await _powerSyncRepository.db().execute(
        '''
          INSERT INTO subscriptions(id, subscriber_id, subscribed_to_id)
            VALUES(uuid(), ?, ?)
      ''',
        [followerId ?? currentUserId!, followToId],
      );
      return;
    }
    await unfollow(
      unfollowId: followToId,
      unfollowerId: followerId ?? currentUserId!,
    );
  }

  @override
  Future<void> unfollow({
    required String unfollowId,
    String? unfollowerId,
  }) async {
    if (currentUserId == null) return;
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [unfollowerId ?? currentUserId, unfollowId],
    );
  }

  @override
  Future<void> removeFollower({required String id}) async {
    if (currentUserId == null) return;
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [id, currentUserId],
    );
  }

  @override
  Stream<int> followingsCountOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        'SELECT COUNT(*) AS subscription_count FROM subscriptions '
        'WHERE subscriber_id = ?',
        parameters: [userId],
      ).map(
        (event) => event
            .safeMap((element) => element['subscription_count'])
            .first as int,
      );

  @override
  Future<List<User>> getFollowers({required String userId}) async {
    final followersId = await _powerSyncRepository.db().getAll(
      'SELECT subscriber_id FROM subscriptions WHERE subscribed_to_id = ? ',
      [userId],
    );
    if (followersId.isEmpty) return [];

    final followers = <User>[];
    for (final followerId in followersId) {
      final result = await _powerSyncRepository.db().execute(
        'SELECT * FROM profiles WHERE id = ?',
        [followerId['subscriber_id']],
      );
      if (result.isEmpty) continue;
      final follower = User.fromJson(result.first);
      followers.add(follower);
    }
    return followers;
  }

  @override
  Stream<List<User>> streamFollowers({required String userId}) async* {
    final streamResult = _powerSyncRepository.db().watch(
      'SELECT subscriber_id FROM subscriptions WHERE subscribed_to_id = ? ',
      parameters: [userId],
    );
    await for (final result in streamResult) {
      final followers = <User>[];
      final followersFutures = await Future.wait(
        result.where((row) => row.isNotEmpty).safeMap(
              (row) => _powerSyncRepository.db().getOptional(
                'SELECT * FROM profiles WHERE id = ?',
                [row['subscriber_id']],
              ),
            ),
      );
      for (final user in followersFutures) {
        if (user == null) continue;
        final follower = User.fromJson(user);
        followers.add(follower);
      }
      yield followers;
    }
  }

  @override
  Future<List<User>> getFollowings({required String userId}) async {
    final followingsUserId = await _powerSyncRepository.db().getAll(
      'SELECT subscribed_to_id FROM subscriptions WHERE subscriber_id = ? ',
      [userId],
    );
    if (followingsUserId.isEmpty) return [];

    final followings = <User>[];
    for (final followingsUserId in followingsUserId) {
      final result = await _powerSyncRepository.db().execute(
        'SELECT * FROM profiles WHERE id = ?',
        [followingsUserId['subscribed_to_id']],
      );
      if (result.isEmpty) continue;
      final following = User.fromJson(result.first);
      followings.add(following);
    }
    return followings;
  }

  @override
  Stream<List<User>> streamFollowings({required String userId}) async* {
    final streamResult = _powerSyncRepository.db().watch(
      'SELECT subscribed_to_id FROM subscriptions WHERE subscriber_id = ? ',
      parameters: [userId],
    );
    await for (final result in streamResult) {
      final followings = <User>[];
      final followingsFutures = await Future.wait(
        result.where((row) => row.isNotEmpty).safeMap(
              (row) => _powerSyncRepository.db().getOptional(
                'SELECT * FROM profiles WHERE id = ?',
                [row['subscribed_to_id']],
              ),
            ),
      );
      for (final user in followingsFutures) {
        if (user == null) continue;
        final following = User.fromJson(user);
        followings.add(following);
      }
      yield followings;
    }
  }

  @override
  Future<bool> isFollowed({
    required String followerId,
    required String userId,
  }) async {
    final result = await _powerSyncRepository.db().execute(
      '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
      [followerId, userId],
    );
    return result.isNotEmpty;
  }

  @override
  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  }) async* {
    if (followerId == null && currentUserId == null) return;
    yield* _powerSyncRepository.db().watch(
      '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
      parameters: [followerId ?? currentUserId, userId],
    ).map((event) => event.isNotEmpty);
  }

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
        (result) => result.safeMap(Comment.fromRow).toList(growable: false),
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
    required User sender,
    required User receiver,
    required Message sharedPostMessage,
    Message? message,
    PostAuthor? postAuthor,
  }) async {
    final exists = await _powerSyncRepository.db().execute(
      '''
SELECT 1 FROM posts WHERE id = ?
''',
      [id],
    );
    if (exists.isEmpty) return;
    final conversation = await _powerSyncRepository.db().execute(
      '''
SELECT conversation_id
  FROM participants
WHERE user_id = ?
  AND conversation_id IN (
      SELECT conversation_id
      FROM participants
      WHERE user_id = ?
    );
''',
      [sender.id, receiver.id],
    );
    if (conversation.isNotEmpty) {
      final chatId = conversation.first['conversation_id'] as String;
      await Future.wait([
        sendMessage(
          chatId: chatId,
          sender: sender,
          receiver: receiver,
          message: sharedPostMessage,
          postAuthor: postAuthor,
        ),
        if (message != null)
          sendMessage(
            chatId: chatId,
            sender: sender,
            receiver: receiver,
            message: message,
          ),
      ]);
      return;
    }
    final newChatId = uuid.v4();
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
      [uuid.v4(), sender.id, newChatId],
    );
    final addParticipant2 = _powerSyncRepository.db().execute(
      '''
insert into
  participants (id, user_id, conversation_id)
  values
  (?, ?, ?)
  ''',
      [uuid.v4(), receiver.id, newChatId],
    );
    await createdConversation
        .whenComplete(() => Future.wait([addParticipant1, addParticipant2]));

    await Future.wait([
      sendMessage(
        chatId: newChatId,
        sender: sender,
        receiver: receiver,
        message: sharedPostMessage,
        postAuthor: postAuthor,
      ),
      if (message != null)
        sendMessage(
          chatId: newChatId,
          sender: sender,
          receiver: receiver,
          message: message,
        ),
    ]);
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
        (result) => result.safeMap(Comment.fromRow).toList(growable: false),
      );

  @override
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
    String? password,
  }) =>
      _powerSyncRepository.updateUser({
        if (fullName != null) 'full_name': fullName,
        if (email != null) 'email': email,
        if (username != null) 'username': username,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (pushToken != null) 'push_token': pushToken,
        if (password != null) 'password': password,
      });

  @override
  Future<void> resetPasswordForEmail({
    required String email,
    String? redirectTo,
  }) =>
      _powerSyncRepository.resetPassword(email: email, redirectTo: redirectTo);

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String newPassword,
  }) async {
    try {
      await _powerSyncRepository.verifyOTP(token: token, email: email);
      await updateUser(password: newPassword);
    } catch (error, stackTrace) {
      logE('Failed to verify OTP.', error: error, stackTrace: stackTrace);
      throw Exception('Failed to verify OTP.');
    }
  }

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
      ).map(
        (event) => event.safeMap(ChatInbox.fromRow).toList(growable: false),
      );

  @override
  Future<ChatInbox> getChat({
    required String chatId,
    required String userId,
  }) async {
    final row = await _powerSyncRepository.db().get(
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
  and c.id = ?2
''',
      [userId, chatId],
    );
    return ChatInbox.fromRow(row);
  }

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
  p.created_at as shared_post_created_at,
  p.media as shared_post_media,
  p_author.id as shared_post_author_id,
  p_author.username as shared_post_author_username,
  p_author.full_name as shared_post_author_full_name,
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
      ).map(
        (event) => event.safeMap(Message.fromRow).toList(growable: false),
      );

  @override
  Future<void> createChat({
    required String userId,
    required String participantId,
  }) async {
    final alreadyExists = await _powerSyncRepository.db().getOptional(
      '''
      SELECT 1
      FROM conversations c
      JOIN participants p1 ON c.id = p1.conversation_id
      JOIN participants p2 ON c.id = p2.conversation_id
      WHERE p1.user_id = ? AND p2.user_id = ?
  ''',
      [userId, participantId],
    );
    if (alreadyExists != null) return;
    final conversationId = uuid.v4();
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
      [uuid.v4(), userId, conversationId],
    );
    final addParticipant2 = _powerSyncRepository.db().execute(
      '''
insert into
  participants (id, user_id, conversation_id)
  values
  (?, ?, ?)
  ''',
      [uuid.v4(), participantId, conversationId],
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
//       final isParticipantInConversation = await _powerSyncRepository.db()
// .get(
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
    required User sender,
    required User receiver,
    required Message message,
    PostAuthor? postAuthor,
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
            sender.id,
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

        try {
          final receivePort = ReceivePort();

          await Isolate.spawn(sendBackgroundNotification, [
            receivePort.sendPort,
            receiver,
            sender,
            message,
            postAuthor,
            chatId,
          ]);
        } catch (error) {
          logE('Error send notification: $error');
        }
      });

  /// Sends notification in a background isolate.
  static Future<void> sendBackgroundNotification(List<dynamic> args) async {
    await sendNotification(
      reciever: args[1] as User,
      sender: args[2] as User,
      message: args[3] as Message,
      postAuthor: args[4] as PostAuthor?,
      chatId: args[5] as String,
    );
    Isolate.exit(args[0] as SendPort, args);
  }

  /// Sends notification using Google APIs to user.
  static Future<void> sendNotification({
    required User reciever,
    required User sender,
    String? chatId,
    Message? message,
    PostAuthor? postAuthor,
  }) async {
    final notificationMessage = postAuthor != null
        ? 'Sent post by ${postAuthor.username}'
        : message?.message;
    final notificationBody =
        '(${reciever.displayUsername}): ${sender.displayUsername}: '
        '$notificationMessage';

    final data = {
      'to': reciever.pushToken,
      'content_available': true,
      'priority': 10,
      'notification': {
        'title': 'Instagram',
        'body': notificationBody,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
      'data': {
        if (chatId != null) 'chat_id': chatId,
      },
    };

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'key=${EnvProd.fcmServerKey}',
    };

    final res = await Dio().post<String>(
      'https://fcm.googleapis.com/fcm/send',
      data: jsonEncode(data),
      options: Options(headers: headers),
    );
    logD('Response: $res, \n status code: ${res.statusCode}');
  }

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
    String? excludeUserIds,
  }) async {
    if (query == null || query.trim().isEmpty) return <User>[];
    query = query.removeSpecialCharacters();
    final excludeUserIdsStatement =
        excludeUserIds == null ? '' : 'AND id NOT IN ($excludeUserIds)';

    final result = await _powerSyncRepository.db().getAll(
      '''
SELECT id, avatar_url, full_name, username
  FROM profiles
WHERE (LOWER(username) LIKE LOWER('%$query%') OR LOWER(full_name) LIKE LOWER('%$query%'))
  AND id <> ?1 $excludeUserIdsStatement 
LIMIT ?2 OFFSET ?3
''',
      [userId, limit, offset],
    );

    return result.safeMap(User.fromJson).toList(growable: false);
  }

  @override
  Future<void> createStory({
    required User author,
    required StoryContentType contentType,
    required String contentUrl,
    String? id,
    int? duration,
  }) =>
      _powerSyncRepository.db().execute(
        '''
insert into stories (id, user_id, content_type, content_url, duration, created_at, expires_at)
values (?, ?, ?, ?, ?, ?, ?)
''',
        [
          id ?? uuid.v4(),
          author.id,
          contentType.toJson(),
          contentUrl,
          duration,
          DateTime.timestamp().toIso8601String(),
          DateTime.timestamp().add(1.days).toIso8601String(),
        ],
      );

  @override
  Future<void> deleteStory({required String id}) =>
      _powerSyncRepository.db().execute(
        '''
DELETE FROM stories WHERE id = ?
''',
        [id],
      );

  @override
  Stream<List<Story>> getStories({
    required String userId,
    bool includeAuthor = true,
  }) =>
      _powerSyncRepository.db().watch(
        '''
SELECT 
  s.*${includeAuthor ? ', p.id as user_id, p.username, p.full_name, p.avatar_url' : ''}
FROM stories s
  ${includeAuthor ? 'LEFT JOIN profiles p ON s.user_id = p.id' : ''}
WHERE user_id = ? AND expires_at > current_timestamp
''',
        parameters: [userId],
      ).map((event) => event.safeMap(Story.fromJson).toList(growable: false));

  @override
  Future<Story> getStory({required String id}) async {
    final row = await _powerSyncRepository.db().execute(
      '''
SELECT * FROM stories WHERE id = ?
''',
      [id],
    );
    if (row.isEmpty) return Story.empty;
    return Story.fromJson(row.first);
  }

  @override
  Future<String> uploadStoryMedia({
    required String storyId,
    required File imageFile,
    required Uint8List imageBytes,
  }) async {
    final stories = _powerSyncRepository.supabase.storage.from('stories');
    final imageExtension = imageFile.path.split('.').last.toLowerCase();
    final imagePath = '$storyId/image';

    await stories.uploadBinary(
      imagePath,
      imageBytes,
      fileOptions: FileOptions(
        contentType: 'image/$imageExtension',
        cacheControl: '9000000',
      ),
    );
    return stories.getPublicUrl(imagePath);
  }

  @override
  Future<List<User>> getPostLikers({
    required String postId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await _powerSyncRepository.db().getAll(
      '''
SELECT up.id, up.username, up.avatar_url
FROM profiles up
INNER JOIN likes l ON up.id = l.user_id
INNER JOIN posts p ON l.post_id = p.id
WHERE p.post_id ?
LIMIT ? OFFSET ?
''',
      [postId, limit, offset],
    );
    if (result.isEmpty) return [];
    return result.safeMap(User.fromJson).toList(growable: false);
  }

  @override
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  }) async {
    final result = await _powerSyncRepository.db().getAll(
      '''
SELECT id, avatar_url, username, full_name
FROM profiles
WHERE id IN (
    SELECT l.user_id
    FROM likes l
    WHERE l.post_id = ?1
    AND EXISTS (
        SELECT *
        FROM subscriptions f
        WHERE f.subscribed_to_id = l.user_Id
        AND f.subscriber_id = ?2
    ) AND id <> ?2
)
LIMIT ?3 OFFSET ?4
''',
      [postId, currentUserId, limit, offset],
    );
    if (result.isEmpty) return [];
    return result.safeMap(User.fromJson).toList(growable: false);
  }
}
