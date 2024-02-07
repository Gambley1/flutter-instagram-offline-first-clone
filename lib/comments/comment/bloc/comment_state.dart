part of 'comment_bloc.dart';

enum CommentStatus { initial, loading, success, failure }

@JsonSerializable()
class CommentState extends Equatable {
  const CommentState({
    required this.status,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isOwner,
    required this.isLikedByOwner,
    this.repliedComments,
  });

  factory CommentState.fromJson(Map<String, dynamic> json) =>
      _$CommentStateFromJson(json);

  const CommentState.intital()
      : this(
          status: CommentStatus.initial,
          likes: 0,
          comments: 0,
          isLiked: false,
          isOwner: false,
          isLikedByOwner: false,
        );

  Map<String, dynamic> toJson() => _$CommentStateToJson(this);

  final CommentStatus status;
  final List<Comment>? repliedComments;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isOwner;
  final bool isLikedByOwner;

  @override
  List<Object?> get props => [
        status,
        repliedComments,
        likes,
        comments,
        isLiked,
        isOwner,
        isLikedByOwner,
      ];

  CommentState copyWith({
    CommentStatus? status,
    List<Comment>? repliedComments,
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isOwner,
    bool? isLikedByOwner,
  }) {
    return CommentState(
      status: status ?? this.status,
      repliedComments: repliedComments ?? this.repliedComments,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isOwner: isOwner ?? this.isOwner,
      isLikedByOwner: isLikedByOwner ?? this.isLikedByOwner,
    );
  }
}
