import 'package:json_annotation/json_annotation.dart';
import 'package:shared/src/models/story.dart';

/// {@template stories_converter}
/// The converter for list of [Story].
class StoriesConverter
    extends JsonConverter<List<Story>, List<Map<String, dynamic>>> {
  /// {@macro stories_converter}
  const StoriesConverter();

  @override
  List<Story> fromJson(List<Map<String, dynamic>> json) {
    return json
        .map((dynamic e) => Story.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<Story> object) {
    return object.map((b) => b.toJson()).toList();
  }
}
