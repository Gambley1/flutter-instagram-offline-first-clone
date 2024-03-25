// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'comments_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentsState _$CommentsStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CommentsState',
      json,
      ($checkedConvert) {
        final val = CommentsState(
          status: $checkedConvert(
              'status', (v) => $enumDecode(_$CommentsStatusEnumMap, v)),
          comments: $checkedConvert(
              'comments',
              (v) => (v as List<dynamic>)
                  .map((e) => Comment.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$CommentsStateToJson(CommentsState instance) =>
    <String, dynamic>{
      'status': _$CommentsStatusEnumMap[instance.status]!,
      'comments': instance.comments.map((e) => e.toJson()).toList(),
    };

const _$CommentsStatusEnumMap = {
  CommentsStatus.initial: 'initial',
  CommentsStatus.populated: 'populated',
  CommentsStatus.error: 'error',
};
