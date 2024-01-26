import 'package:equatable/equatable.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unknown_block.g.dart';

/// {@template unknown_block}
/// A block which represents an unknown type.
/// {@endtemplate}
@JsonSerializable()
class UnknownBlock extends InstaBlock with EquatableMixin {
  /// {@macro unknown_block}
  UnknownBlock({super.type = UnknownBlock.identifier});

  /// Converts a `Map<String, dynamic>` into a [UnknownBlock] instance.
  factory UnknownBlock.fromJson(Map<String, dynamic> json) =>
      _$UnknownBlockFromJson(json);

  /// The unknown block type identifier.
  static const identifier = '__unknown__';

  @override
  Map<String, dynamic> toJson() => _$UnknownBlockToJson(this);

  @override
  List<Object> get props => [type];
}
