// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'reels_bloc.dart';

enum ReelsStatus { initial, loading, success, failure }

class ReelsState extends Equatable {
  const ReelsState._({required this.status, required this.blocks});

  const ReelsState.intital()
      : this._(status: ReelsStatus.initial, blocks: const []);

  final ReelsStatus status;
  final List<InstaBlock> blocks;

  @override
  List<Object?> get props => [status, blocks];

  ReelsState copyWith({
    ReelsStatus? status,
    List<InstaBlock>? blocks,
  }) {
    return ReelsState._(
      status: status ?? this.status,
      blocks: blocks ?? this.blocks,
    );
  }
}
