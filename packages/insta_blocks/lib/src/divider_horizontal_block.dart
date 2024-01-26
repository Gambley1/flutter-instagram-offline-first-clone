import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/shared.dart';

part 'divider_horizontal_block.g.dart';

/// {@template divider_horizontal_block}
/// A block which represents a divider horizontal.
/// {@endtemplate}
@JsonSerializable()
class DividerHorizontalBlock extends InstaBlock with EquatableMixin {
  /// {@macro divider_horizontal_block}
  DividerHorizontalBlock({
    super.type = DividerHorizontalBlock.identifier,
  });

  /// Converts a `Map<String, dynamic>` into
  /// a [DividerHorizontalBlock] instance.
  factory DividerHorizontalBlock.fromJson(Map<String, dynamic> json) =>
      _$DividerHorizontalBlockFromJson(json);

  /// The divider horizontal block type identifier.
  static const identifier = '__divider_horizontal__';

  @override
  Map<String, dynamic> toJson() => _$DividerHorizontalBlockToJson(this);

  @override
  List<Object?> get props => [type];
}
