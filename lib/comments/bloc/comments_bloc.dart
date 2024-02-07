import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

part 'comments_bloc.g.dart';
part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends HydratedBloc<CommentsEvent, CommentsState> {
  CommentsBloc({
    required String postId,
    required PostsRepository postsRepository,
  })  : _postId = postId,
        _postsRepository = postsRepository,
        super(const CommentsState.initial()) {
    on<CommentsSubscriptionRequested>(
      _onCommentsSubscriptionRequested,
      transformer: throttleDroppable(),
    );
    on<CommentsCommentCreateRequested>(_onCommentsCommentCreateRequested);
  }

  final String _postId;

  @override
  String get id => _postId;

  final PostsRepository _postsRepository;

  Future<void> _onCommentsSubscriptionRequested(
    CommentsSubscriptionRequested event,
    Emitter<CommentsState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.commentsOf(postId: id),
      onData: (comments) => state.copyWith(comments: comments),
    );
  }

  Future<void> _onCommentsCommentCreateRequested(
    CommentsCommentCreateRequested event,
    Emitter<CommentsState> emit,
  ) =>
      _postsRepository.createComment(
        postId: id,
        userId: event.userId,
        content: event.content,
        repliedToCommentId: event.repliedToCommentId,
      );

  @override
  CommentsState? fromJson(Map<String, dynamic> json) =>
      CommentsState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(CommentsState state) => state.toJson();
}
