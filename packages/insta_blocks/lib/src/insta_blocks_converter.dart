import 'package:insta_blocks/insta_blocks.dart';
import 'package:json_annotation/json_annotation.dart';

/// {@template insta_blocks_converter}
/// A [JsonConverter] that supports (de)serializing a `List<InstaBlock>`.
/// {@endtemplate}
class InstaBlocksConverter
    implements JsonConverter<List<InstaBlock>, List<Map<String, dynamic>>> {
  /// {@macro insta_blocks_converter}
  const InstaBlocksConverter();

  @override
  List<InstaBlock> fromJson(List<Map<String, dynamic>> jsonString) {
    return jsonString
        .map((dynamic e) => InstaBlock.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<InstaBlock> blocks) {
    return blocks.map((b) => b.toJson()).toList();
  }
}
