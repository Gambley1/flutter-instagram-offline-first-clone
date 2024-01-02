// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'comments_bloc.dart';

enum CommentsStatus { initial, populated, error }

class CommentsState extends Equatable {
  const CommentsState._({required this.status, required this.comments});

  const CommentsState.initial()
      : this._(status: CommentsStatus.initial, comments: const []);

  final CommentsStatus status;
  final List<Comment> comments;

  @override
  List<Object> get props => [status, comments];

  CommentsState copyWith({
    CommentsStatus? status,
    List<Comment>? comments,
  }) {
    return CommentsState._(
      status: status ?? this.status,
      comments: comments ?? this.comments,
    );
  }
}
