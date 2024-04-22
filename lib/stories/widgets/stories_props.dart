import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

typedef OnStorySeen = void Function(int storyIndex, List<Story> stories);

class StoriesProps {
  const StoriesProps({
    required this.stories,
    required this.author,
    this.onStorySeen,
  });

  final User author;
  final List<Story> stories;
  final OnStorySeen? onStorySeen;
}
