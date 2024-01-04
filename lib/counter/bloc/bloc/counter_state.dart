// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'counter_bloc.dart';

enum CounterStatus { initial, loading, success, failure }

class CounterState extends Equatable {
  const CounterState._({required this.status, required this.count});

  const CounterState.intital()
      : this._(status: CounterStatus.initial, count: 0);

  final CounterStatus status;
  final int count;

  @override
  List<Object?> get props => [status, count];

  CounterState copyWith({
    CounterStatus? status,
    int? count,
  }) {
    return CounterState._(
      status: status ?? this.status,
      count: count ?? this.count,
    );
  }
}
