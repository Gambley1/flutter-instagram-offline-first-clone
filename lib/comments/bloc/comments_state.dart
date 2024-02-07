part of 'comments_bloc.dart';

enum CommentsStatus { initial, populated, error }

@JsonSerializable()
class CommentsState extends Equatable {
  const CommentsState({required this.status, required this.comments});

  factory CommentsState.fromJson(Map<String, dynamic> json) =>
      _$CommentsStateFromJson(json);

  const CommentsState.initial()
      : this(status: CommentsStatus.initial, comments: const []);

  Map<String, dynamic> toJson() => _$CommentsStateToJson(this);

  final CommentsStatus status;
  final List<Comment> comments;

  @override
  List<Object> get props => [status, comments];

  CommentsState copyWith({
    CommentsStatus? status,
    List<Comment>? comments,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
    );
  }
}
