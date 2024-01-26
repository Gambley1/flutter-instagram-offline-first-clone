import 'package:insta_blocks/insta_blocks.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// {@template insta_block}
/// A reusable Instagram Block which represents a content-based component.
/// {@endtemplate}
@immutable
@JsonSerializable()
abstract class InstaBlock {
  /// {@macro insta_bloc}
  const InstaBlock({required this.type});

  /// The block type key used to identify the type of block/metadata.
  final String type;

  /// Converts current instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson();

  /// Deserialize [json] into a [InstaBlock] instance.
  /// Returns [UnknownBlock] when the [json] is not recognized;
  static InstaBlock fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case PostLargeBlock.identifier:
        return PostLargeBlock.fromJson(json);
      case PostSmallBlock.identifier:
        return PostSmallBlock.fromJson(json);
      case PostSponsoredBlock.identifier:
        return PostSponsoredBlock.fromJson(json);
      case DividerHorizontalBlock.identifier:
        return DividerHorizontalBlock.fromJson(json);
      case SectionHeaderBlock.identifier:
        return SectionHeaderBlock.fromJson(json);
    }
    return UnknownBlock();
  }
}
