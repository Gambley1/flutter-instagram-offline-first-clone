// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'user_stories_bloc.dart';

@immutable
@JsonSerializable()
class UserStoriesState extends Equatable {
  const UserStoriesState({
    required this.author,
    required this.stories,
    required this.showStories,
  });

  const UserStoriesState.intital()
      : this(
          author: User.anonymous,
          stories: const [],
          showStories: false,
        );

  final User author;
  final List<Story> stories;
  final bool showStories;

  factory UserStoriesState.fromJson(Map<String, dynamic> json) =>
      _$UserStoriesStateFromJson(json);

  Map<String, dynamic> toJson() => _$UserStoriesStateToJson(this);

  @override
  List<Object?> get props => [author, stories, showStories];

  UserStoriesState copyWith({
    User? author,
    List<Story>? stories,
    bool? showStories,
  }) {
    return UserStoriesState(
      author: author ?? this.author,
      stories: stories ?? this.stories,
      showStories: showStories ?? this.showStories,
    );
  }
}
