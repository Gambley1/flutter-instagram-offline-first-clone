// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'attachment_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PreparingImpl _$$PreparingImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$PreparingImpl',
      json,
      ($checkedConvert) {
        final val = _$PreparingImpl(
          $type: $checkedConvert('runtimeType', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {r'$type': 'runtimeType'},
    );

Map<String, dynamic> _$$PreparingImplToJson(_$PreparingImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$InProgressImpl _$$InProgressImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$InProgressImpl',
      json,
      ($checkedConvert) {
        final val = _$InProgressImpl(
          uploaded: $checkedConvert('uploaded', (v) => v as int),
          total: $checkedConvert('total', (v) => v as int),
          $type: $checkedConvert('runtimeType', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {r'$type': 'runtimeType'},
    );

Map<String, dynamic> _$$InProgressImplToJson(_$InProgressImpl instance) =>
    <String, dynamic>{
      'uploaded': instance.uploaded,
      'total': instance.total,
      'runtimeType': instance.$type,
    };

_$SuccessImpl _$$SuccessImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$SuccessImpl',
      json,
      ($checkedConvert) {
        final val = _$SuccessImpl(
          $type: $checkedConvert('runtimeType', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {r'$type': 'runtimeType'},
    );

Map<String, dynamic> _$$SuccessImplToJson(_$SuccessImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$FailedImpl _$$FailedImplFromJson(Map<String, dynamic> json) => $checkedCreate(
      r'_$FailedImpl',
      json,
      ($checkedConvert) {
        final val = _$FailedImpl(
          error: $checkedConvert('error', (v) => v as String),
          $type: $checkedConvert('runtimeType', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {r'$type': 'runtimeType'},
    );

Map<String, dynamic> _$$FailedImplToJson(_$FailedImpl instance) =>
    <String, dynamic>{
      'error': instance.error,
      'runtimeType': instance.$type,
    };
