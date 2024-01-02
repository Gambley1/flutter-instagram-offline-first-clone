import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  CommentsBloc({
    required PostsRepository postsRepository,
  })  : _postsRepository = postsRepository,
        super(const CommentsState.initial()) {
    on<CommentsPostCommentRequested>(_onCommentPostRequested);
    on<CommentsLikeCommentRequested>(_onCommentLikeRequested);
    on<CommentsCommentDeleteRequested>(_onCommentDeleteRequested);
  }

  final PostsRepository _postsRepository;

  Stream<List<Comment>> commentsOf(String postId) =>
      _postsRepository.commentsOf(postId: postId);

  Stream<bool> isLiked({required String commentId, required String userId}) =>
      _postsRepository.isLiked(
        id: commentId,
        userId: userId,
        post: false,
      );

  Stream<bool> isLikedByOwner({
    required String commentId,
    required String userId,
  }) =>
      isLiked(commentId: commentId, userId: userId);

  Stream<int> likesOf(String commentdId) =>
      _postsRepository.likesOf(id: commentdId, post: false);

  Stream<List<Comment>> repliedCommentsOf(String commentId) =>
      _postsRepository.repliedCommentsOf(commentId: commentId);

  Future<void> _onCommentPostRequested(
    CommentsPostCommentRequested event,
    Emitter<CommentsState> emit,
  ) =>
      _postsRepository.createComment(
        content: event.content,
        postId: event.postId,
        userId: event.userId,
        repliedToCommentId: event.repliedToCommentId,
      );

  Future<void> _onCommentLikeRequested(
    CommentsLikeCommentRequested event,
    Emitter<CommentsState> emit,
  ) =>
      _postsRepository.like(
        id: event.commentId,
        userId: event.userId,
        post: false,
      );

  Future<void> _onCommentDeleteRequested(
    CommentsCommentDeleteRequested event,
    Emitter<CommentsState> emit,
  ) =>
      _postsRepository.deleteComment(id: event.commentId);
}
