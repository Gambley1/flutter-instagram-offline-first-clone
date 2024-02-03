part of 'reels_bloc.dart';

sealed class ReelsEvent extends Equatable {
  const ReelsEvent();

  @override
  List<Object> get props => [];
}

final class ReelsPageRequested extends ReelsEvent {
  const ReelsPageRequested({this.page = 0});

  final int page;
}

final class ReelsCreateReelRequested extends ReelsEvent {
  const ReelsCreateReelRequested({
    required this.postId,
    required this.userId,
    required this.caption,
    required this.media,
  });

  final String postId;
  final String userId;
  final String caption;
  final List<Map<String, dynamic>> media;
}
