import 'package:equatable/equatable.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:json_annotation/json_annotation.dart';

part 'divider_horizontal_block.g.dart';

/// {@template divider_horizontal_block}
/// A block which represents a divider horizontal.
/// {@endtemplate}
@JsonSerializable()
class DividerHorizontalBlock with EquatableMixin implements InstaBlock {
  /// {@macro divider_horizontal_block}
  const DividerHorizontalBlock({
    this.type = DividerHorizontalBlock.identifier,
  });

  /// Converts a `Map<String, dynamic>` into
  /// a [DividerHorizontalBlock] instance.
  factory DividerHorizontalBlock.fromJson(Map<String, dynamic> json) =>
      _$DividerHorizontalBlockFromJson(json);

  /// The divider horizontal block type identifier.
  static const identifier = '__divider_horizontal__';

  @override
  final String type;

  @override
  Map<String, dynamic> toJson() => _$DividerHorizontalBlockToJson(this);

  @override
  List<Object?> get props => [type];
}
