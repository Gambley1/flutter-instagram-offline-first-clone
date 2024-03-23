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
    required String userId,
    bool post = true,
  }) =>
      _databaseClient.like(userId: userId, id: id, post: post);

  @override
  Future<Post?> createPost({
    required String id,
    required String userId,
    required String caption,
    required String media,
  }) =>
      _databaseClient.createPost(
        id: id,
        userId: userId,
        caption: caption,
        media: media,
      );

  @override
  Future<String?> deletePost({required String id}) =>
      _databaseClient.deletePost(id: id);

  @override
  Stream<bool> isLiked({
    required String id,
    required String userId,
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
  Future<void> uploadMedia({
    required String id,
    required String ownerId,
    required String url,
    required String type,
    required String blurHash,
    required String? firstFrame,
  }) =>
      _databaseClient.uploadMedia(
        id: id,
        ownerId: ownerId,
        url: url,
        type: type,
        blurHash: blurHash,
        firstFrame: firstFrame,
      );

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
}
