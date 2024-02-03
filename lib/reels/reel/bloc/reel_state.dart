part of 'reel_bloc.dart';

enum ReelStatus { initial, loading, success, failure }

@JsonSerializable()
class ReelState extends Equatable {
  const ReelState({
    required this.status,
    required this.likes,
    required this.likers,
    required this.commentsCount,
    required this.isLiked,
    required this.isOwner,
    this.isFollowed,
  });

  factory ReelState.fromJson(Map<String, dynamic> json) =>
      _$ReelStateFromJson(json);

  const ReelState.intital()
      : this(
          status: ReelStatus.initial,
          likes: 0,
          likers: const [],
          commentsCount: 0,
          isLiked: false,
          isOwner: false,
        );

  final ReelStatus status;
  final int likes;
  final List<User> likers;
  final int commentsCount;
  final bool isLiked;
  final bool isOwner;
  final bool? isFollowed;

  Map<String, dynamic> toJson() => _$ReelStateToJson(this);

  @override
  List<Object?> get props =>
      [status, likes, isLiked, likers, commentsCount, isOwner, isFollowed];

  ReelState copyWith({
    ReelStatus? status,
    int? likes,
    List<User>? likers,
    int? commentsCount,
    bool? isLiked,
    bool? isOwner,
    bool? isFollowed,
  }) {
    return ReelState(
      status: status ?? this.status,
      likes: likes ?? this.likes,
      likers: likers ?? this.likers,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isOwner: isOwner ?? this.isOwner,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}
