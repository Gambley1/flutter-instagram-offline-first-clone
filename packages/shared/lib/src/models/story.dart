import 'package:equatable/equatable.dart';

/// {@template story}
/// The representation of the Instagram user story model.
class Story extends Equatable {
  /// {@macro story}
  const Story({required this.id});

  /// The identifier of the story.
  final String id;

  @override
  List<Object?> get props => [];
}
