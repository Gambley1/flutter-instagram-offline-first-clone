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

final class ReelsUpdateRequested extends ReelsEvent {
  const ReelsUpdateRequested({
    required this.block,
    this.isCreate = false,
    this.isDelete = false,
  });

  final PostBlock block;
  final bool isCreate;
  final bool isDelete;
}

final class ReelsCreateReelRequested extends ReelsEvent {
  const ReelsCreateReelRequested({
    required this.id,
    required this.userId,
    required this.caption,
    required this.media,
  });

  final String id;
  final String userId;
  final String caption;
  final List<Map<String, dynamic>> media;
}
