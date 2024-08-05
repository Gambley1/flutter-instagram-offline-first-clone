import 'dart:math' as math;

import 'package:database_client/database_client.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

/// {@template posts_repository}
/// A package that manages posts flow.
/// {@endtemplate}
class PostsRepository implements PostsBaseRepository {
  /// {@macro posts_repository}
  const PostsRepository({required DatabaseClient databaseClient})
      : _databaseClient = databaseClient;

  final DatabaseClient _databaseClient;

  @override
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
    bool onlyReels = false,
  }) =>
      _databaseClient.getPage(
        offset: offset,
        limit: limit,
        onlyReels: onlyReels,
      );

  @override
  Future<void> like({
    required String id,
    bool post = true,
  }) =>
      _databaseClient.like(id: id, post: post);

  @override
  Future<Post?> createPost({
    required String id,
    required String caption,
    required String media,
  }) =>
      _databaseClient.createPost(
        id: id,
        caption: caption,
        media: media,
      );

  @override
  Future<String?> deletePost({required String id}) =>
      _databaseClient.deletePost(id: id);

  @override
  Stream<bool> isLiked({
    required String id,
    String? userId,
    bool post = true,
  }) =>
      _databaseClient.isLiked(id: id, userId: userId, post: post);

  @override
  Stream<int> likesOf({required String id, bool post = true}) =>
      _databaseClient.likesOf(id: id, post: post);

  @override
  Stream<int> postsAmountOf({required String userId}) =>
      _databaseClient.postsAmountOf(userId: userId);

  @override
  Stream<List<Post>> postsOf({String? userId}) =>
      _databaseClient.postsOf(userId: userId);

  @override
  Future<Post?> updatePost({
    required String id,
    String? caption,
  }) =>
      _databaseClient.updatePost(id: id, caption: caption);

  @override
  Stream<int> commentsAmountOf({required String postId}) =>
      _databaseClient.commentsAmountOf(postId: postId);

  @override
  Stream<List<Comment>> commentsOf({required String postId}) =>
      _databaseClient.commentsOf(postId: postId);

  @override
  Future<void> createComment({
    required String content,
    required String postId,
    required String userId,
    String? repliedToCommentId,
  }) =>
      _databaseClient.createComment(
        content: content,
        postId: postId,
        userId: userId,
        repliedToCommentId: repliedToCommentId,
      );

  @override
  Future<void> deleteComment({required String id}) =>
      _databaseClient.deleteComment(id: id);

  @override
  Stream<List<Comment>> repliedCommentsOf({required String commentId}) =>
      _databaseClient.repliedCommentsOf(commentId: commentId);

  @override
  Future<void> sharePost({
    required String id,
    required User sender,
    required User receiver,
    required Message sharedPostMessage,
    Message? message,
    PostAuthor? postAuthor,
  }) =>
      _databaseClient.sharePost(
        id: id,
        sender: sender,
        sharedPostMessage: sharedPostMessage,
        message: message,
        receiver: receiver,
        postAuthor: postAuthor,
      );

  @override
  Future<Post?> getPostBy({required String id}) =>
      _databaseClient.getPostBy(id: id);

  @override
  Future<List<User>> getPostLikers({
    required String postId,
    int limit = 30,
    int offset = 0,
  }) =>
      _databaseClient.getPostLikers(
        postId: postId,
        limit: limit,
        offset: offset,
      );

  @override
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  }) =>
      _databaseClient.getPostLikersInFollowings(
        postId: postId,
        limit: limit,
        offset: offset,
      );

  /// Returns a list of recommended posts.
  static final recommendedPosts = <PostLargeBlock>[
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: math.Random().nextInt(60),
          hours: math.Random().nextInt(24),
          days: math.Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/free-photo/morskie-oko-tatry_1204-510.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: math.Random().nextInt(60),
          hours: math.Random().nextInt(24),
          days: math.Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://images.unsplash.com/photo-1722861315999-5de71ce7cdda?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHw0fHx8ZW58MHx8fHx8',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: math.Random().nextInt(60),
          hours: math.Random().nextInt(24),
          days: math.Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/free-photo/beautiful-shot-high-mountains-covered-with-green-plants-near-lake-storm-clouds_181624-7731.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: math.Random().nextInt(60),
          hours: math.Random().nextInt(24),
          days: math.Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/free-photo/landscape-morning-fog-mountains-with-hot-air-balloons-sunrise_335224-794.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: math.Random().nextInt(60),
          hours: math.Random().nextInt(24),
          days: math.Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/free-photo/magical-shot-dolomite-mountains-fanes-sennes-prags-national-park-italy-during-summer_181624-43445.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: math.Random().nextInt(60),
          hours: math.Random().nextInt(24),
          days: math.Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/free-photo/morskie-oko-tatry_1204-510.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: math.Random().nextInt(60),
          hours: math.Random().nextInt(24),
          days: math.Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/premium-photo/clouds-is-top-wooden-boat-crystal-lake-with-majestic-mountain-reflection-water-chapel-is-right-coast_146671-14200.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: math.Random().nextInt(60),
          hours: math.Random().nextInt(24),
          days: math.Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://images.unsplash.com/photo-1722648404028-6454d2a93602?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxMHx8fGVufDB8fHx8fA%3D%3D',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: math.Random().nextInt(60),
          hours: math.Random().nextInt(24),
          days: math.Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/premium-photo/clouds-is-top-wooden-boat-crystal-lake-with-majestic-mountain-reflection-water-chapel-is-right-coast_146671-14200.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
    PostLargeBlock(
      id: uuid.v4(),
      author: PostAuthor.randomConfirmed(),
      createdAt: DateTime.now().subtract(
        Duration(
          minutes: math.Random().nextInt(60),
          hours: math.Random().nextInt(24),
          days: math.Random().nextInt(12),
        ),
      ),
      media: [
        ImageMedia(
          id: uuid.v4(),
          url:
              'https://img.freepik.com/premium-photo/clouds-is-top-wooden-boat-crystal-lake-with-majestic-mountain-reflection-water-chapel-is-right-coast_146671-14200.jpg?size=626&ext=jpg',
        ),
      ],
      caption: 'Hello world!',
    ),
  ].withNavigateToPostAuthorAction;
}
