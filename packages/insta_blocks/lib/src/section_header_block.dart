import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/shared.dart';

part 'section_header_block.g.dart';

/// {@template section_header_block}
/// A block which represents a section header.
/// {@endtemplate}
@JsonSerializable()
class SectionHeaderBlock extends InstaBlock with EquatableMixin {
  /// {@macro section_header_block}
  SectionHeaderBlock({
    required this.title,
    this.action,
    super.type = SectionHeaderBlock.identifier,
  });

  /// Converts a `Map<String, dynamic>` into a [SectionHeaderBlock] instance.
  factory SectionHeaderBlock.fromJson(Map<String, dynamic> json) =>
      _$SectionHeaderBlockFromJson(json);

  /// The section header block type identifier.
  static const identifier = '__section_header__';

  /// The title of the section header.
  final String title;

  /// An optional action which occurs upon interaction.
  @BlockActionConverter()
  final BlockAction? action;

  @override
  Map<String, dynamic> toJson() => _$SectionHeaderBlockToJson(this);

  @override
  List<Object?> get props => [title, action, type];
}
