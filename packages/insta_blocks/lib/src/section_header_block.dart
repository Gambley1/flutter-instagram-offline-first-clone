import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/shared.dart';

part 'section_header_block.g.dart';

/// The type for [SectionHeaderBlock] that identifies what this block is used
/// for
enum SectionHeaderBlockType {
  /// The section header block is used for the suggested posts section.
  suggested,
}

/// {@template section_header_block}
/// A block which represents a section header.
/// {@endtemplate}
@JsonSerializable()
class SectionHeaderBlock extends InstaBlock with EquatableMixin {
  /// {@macro section_header_block}
  const SectionHeaderBlock({
    required this.sectionType,
    this.action,
    super.type = SectionHeaderBlock.identifier,
  });

  /// Converts a `Map<String, dynamic>` into a [SectionHeaderBlock] instance.
  factory SectionHeaderBlock.fromJson(Map<String, dynamic> json) =>
      _$SectionHeaderBlockFromJson(json);

  /// The section header block type identifier.
  static const String identifier = '__section_header__';

  /// The title of the section header.
  final SectionHeaderBlockType sectionType;

  /// An optional action which occurs upon interaction.
  @BlockActionConverter()
  final BlockAction? action;

  @override
  Map<String, dynamic> toJson() => _$SectionHeaderBlockToJson(this);

  @override
  List<Object?> get props => [action, type];
}
