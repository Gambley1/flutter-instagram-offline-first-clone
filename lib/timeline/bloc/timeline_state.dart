// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'timeline_bloc.dart';

enum TimelineStatus { initial, loading, populated, failure }

class TimelineState extends Equatable {
  const TimelineState._({required this.status, required this.timeline});

  const TimelineState.intital()
      : this._(
          status: TimelineStatus.initial,
          timeline: const FeedPage.empty(),
        );

  final TimelineStatus status;
  final FeedPage timeline;

  @override
  List<Object?> get props => [status, timeline];

  TimelineState copyWith({
    TimelineStatus? status,
    FeedPage? timeline,
  }) {
    return TimelineState._(
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
    );
  }
}
