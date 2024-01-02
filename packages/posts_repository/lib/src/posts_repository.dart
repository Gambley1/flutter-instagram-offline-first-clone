import 'package:database_client/database_client.dart';
import 'package:shared/shared.dart';

/// {@template posts_repository}
/// A package that manages posts flow.
/// {@endtemplate}
class PostsRepository implements PostsBaseRepository {
  /// {@macro posts_repository}
  const PostsRepository({required Client client}) : _client = client;

  final Client _client;

  @override
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
  }) =>
      _client.getPage(offset: offset, limit: limit);

  @override
  Future<void> like({
    required String id,
    required String userId,
    bool post = true,
  }) =>
      _client.like(userId: userId, id: id, post: post);

  @override
  Future<Post> createPost({
    required String id,
    required String userId,
    required String caption,
    required String type,
    required String mediaUrl,
    required String imagesUrl,
  }) =>
      _client.createPost(
        id: id,
        userId: userId,
        caption: caption,
        type: type,
        mediaUrl: mediaUrl,
        imagesUrl: imagesUrl,
      );

  @override
  Future<void> deletePost({required String id}) => _client.deletePost(id: id);

  @override
  Stream<bool> isLiked({
    required String id,
    required String userId,
    bool post = true,
  }) =>
      _client.isLiked(id: id, userId: userId, post: post);

  @override
  Stream<int> likesOf({required String id, bool post = true}) =>
      _client.likesOf(id: id, post: post);

  @override
  Stream<int> postsAmountOf({required String userId}) =>
      _client.postsAmountOf(userId: userId);

  @override
  Stream<List<Post>> postsOf({required String currentUserId, String? userId}) =>
      _client.postsOf(currentUserId: currentUserId, userId: userId);

  @override
  Future<void> updatePost({required String id}) => _client.updatePost(id: id);

  @override
  Stream<int> commentsAmountOf({required String postId}) =>
      _client.commentsAmountOf(postId: postId);

  @override
  Stream<List<Comment>> commentsOf({required String postId}) =>
      _client.commentsOf(postId: postId);

  @override
  Future<void> createComment({
    required String content,
    required String postId,
    required String userId,
    String? repliedToCommentId,
  }) =>
      _client.createComment(
        content: content,
        postId: postId,
        userId: userId,
        repliedToCommentId: repliedToCommentId,
      );

  @override
  Future<void> deleteComment({required String id}) =>
      _client.deleteComment(id: id);

  @override
  Stream<List<Comment>> repliedCommentsOf({required String commentId}) =>
      _client.repliedCommentsOf(commentId: commentId);

  @override
  Future<void> sharePost({
    required String id,
    required String senderUserId,
    required Message message,
    String? recipientUserId,
  }) =>
      _client.sharePost(
        id: id,
        senderUserId: senderUserId,
        message: message,
        recipientUserId: recipientUserId,
      );

  @override
  Future<Post?> getPostBy({required String id}) => _client.getPostBy(id: id);
}
