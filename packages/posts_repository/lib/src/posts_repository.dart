import 'package:database_client/database_client.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

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
  Future<void> createPost({
    required String id,
    required String userId,
    required String caption,
    required String media,
  }) =>
      _client.createPost(
        id: id,
        userId: userId,
        caption: caption,
        media: media,
      );

  @override
  Future<String?> deletePost({required String id}) =>
      _client.deletePost(id: id);

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
    required User sender,
    required User receiver,
    required Message message,
    PostAuthor? postAuthor,
  }) =>
      _client.sharePost(
        id: id,
        sender: sender,
        message: message,
        receiver: receiver,
        postAuthor: postAuthor,
      );

  @override
  Future<Post?> getPostBy({required String id}) => _client.getPostBy(id: id);

  @override
  Future<void> uploadMedia({
    required String id,
    required String ownerId,
    required String url,
    required String type,
    required String blurHash,
    required String? firstFrame,
  }) =>
      _client.uploadMedia(
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
      _client.getPostLikers(postId: postId, limit: limit, offset: offset);

  @override
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  }) =>
      _client.getPostLikersInFollowings(
        postId: postId,
        limit: limit,
        offset: offset,
      );
}
