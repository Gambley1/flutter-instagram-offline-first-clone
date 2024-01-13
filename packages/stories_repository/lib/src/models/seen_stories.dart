// ignore_for_file:  sort_constructors_first
// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

/// {@template seen_stories}
/// The object that contains seen [stories] associated with a user by [userId].
/// {@endtemplate}
class SeenStories extends Equatable {
  /// {@macro seen_stories}
  const SeenStories({
    this.userId = '',
    this.stories = const [],
  });

  factory SeenStories.fromJson(Map<String, dynamic> json) {
    return SeenStories(
      userId: json['user_id'] as String,
      stories: List<Story>.from(
        (json['stories'] as List).map<Story>(
          (x) => Story.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  /// The user that has seen the [stories].
  final String userId;

  /// The stories that the user by [userId] has seen.
  final List<Story> stories;

  static const empty = SeenStories();

  @override
  List<Object> get props => [userId, stories];

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'stories': stories.map((x) => x.toJson()).toList(),
      };

  SeenStories copyWith({
    String? userId,
    List<Story>? stories,
  }) {
    return SeenStories(
      userId: userId ?? this.userId,
      stories: stories ?? this.stories,
    );
  }
}
