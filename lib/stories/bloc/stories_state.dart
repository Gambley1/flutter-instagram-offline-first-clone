// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'stories_bloc.dart';

enum StoriesStatus { initial, loading, success, failure }

class StoriesState extends Equatable {
  const StoriesState._({required this.status, required this.users});

  const StoriesState.intital()
      : this._(status: StoriesStatus.initial, users: const []);

  final StoriesStatus status;
  final List<User> users;

  @override
  List<Object?> get props => [status, users];

  StoriesState copyWith({
    StoriesStatus? status,
    List<User>? users,
  }) {
    return StoriesState._(
      status: status ?? this.status,
      users: users ?? this.users,
    );
  }
}
