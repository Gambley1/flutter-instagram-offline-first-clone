part of 'timeline_bloc.dart';

sealed class TimelineEvent extends Equatable {
  const TimelineEvent();

  @override
  List<Object?> get props => [];
}

final class TimelinePageRequested extends TimelineEvent {
  const TimelinePageRequested({this.page});

  final int? page;

  @override
  List<Object?> get props => [page];
}

final class TimelineRefreshRequested extends TimelineEvent {
  const TimelineRefreshRequested();
}
