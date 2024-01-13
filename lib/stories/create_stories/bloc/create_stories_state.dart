part of 'create_stories_bloc.dart';

enum CreateStoriesStatus { initial, loading, success, failure }

class CreateStoriesState extends Equatable {
  const CreateStoriesState._({
    required this.status,
    required this.isAvailable,
  });

  const CreateStoriesState.intital()
      : this._(status: CreateStoriesStatus.initial, isAvailable: true);

  final CreateStoriesStatus status;
  final bool isAvailable;

  @override
  List<Object?> get props => [status, isAvailable];

  CreateStoriesState copyWith({
    CreateStoriesStatus? status,
    bool? isAvailable,
  }) {
    return CreateStoriesState._(
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
