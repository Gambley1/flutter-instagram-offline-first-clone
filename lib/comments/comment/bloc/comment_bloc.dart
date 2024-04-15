import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

part 'comment_bloc.g.dart';
part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends HydratedBloc<CommentEvent, CommentState> {
  CommentBloc({
    required String commentId,
    required PostsRepository postsRepository,
  })  : _commentId = commentId,
        _postsRepository = postsRepository,
        super(const CommentState.initial()) {
    on<CommentLikesSubscriptionRequested>(
      _onCommentLikesSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<CommentIsLikedSubscriptionRequested>(
      _onCommentIsLikedSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<CommentIsLikedByOwnerSubscriptionRequested>(
      _onCommentIsLikedByOwnerSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<CommentsRepliedCommentsSubscriptionRequested>(
      _onCommentsRepliedCommentsSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<CommentLikeRequested>(_onCommentLikeRequested);
    on<CommentDeleteRequested>(_onCommentDeleteRequested);
  }

  final String _commentId;
  final PostsRepository _postsRepository;

  @override
  String get id => _commentId;

  Future<void> _onCommentLikeRequested(
    CommentLikeRequested event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await _postsRepository.like(id: id, post: false);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  Future<void> _onCommentDeleteRequested(
    CommentDeleteRequested event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await _postsRepository.deleteComment(id: id);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  Future<void> _onCommentLikesSubscriptionRequested(
    CommentLikesSubscriptionRequested event,
    Emitter<CommentState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.likesOf(id: id, post: false),
      onData: (likes) => state.copyWith(likes: likes),
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state.copyWith(status: CommentStatus.failure);
      },
    );
  }

  Future<void> _onCommentIsLikedSubscriptionRequested(
    CommentIsLikedSubscriptionRequested event,
    Emitter<CommentState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.isLiked(id: id, post: false),
      onData: (isLiked) => state.copyWith(isLiked: isLiked),
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state.copyWith(status: CommentStatus.failure);
      },
    );
  }

  Future<void> _onCommentIsLikedByOwnerSubscriptionRequested(
    CommentIsLikedByOwnerSubscriptionRequested event,
    Emitter<CommentState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.isLiked(id: id, userId: event.ownerId, post: false),
      onData: (isLikedByOwner) =>
          state.copyWith(isLikedByOwner: isLikedByOwner),
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state.copyWith(status: CommentStatus.failure);
      },
    );
  }

  Future<void> _onCommentsRepliedCommentsSubscriptionRequested(
    CommentsRepliedCommentsSubscriptionRequested event,
    Emitter<CommentState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.repliedCommentsOf(commentId: event.commentId),
      onData: (repliedComments) =>
          state.copyWith(repliedComments: repliedComments),
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state.copyWith(status: CommentStatus.failure);
      },
    );
  }

  @override
  CommentState? fromJson(Map<String, dynamic> json) =>
      CommentState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(CommentState state) => state.toJson();
}
