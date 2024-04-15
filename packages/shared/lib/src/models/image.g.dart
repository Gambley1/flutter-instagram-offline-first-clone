// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageMedia _$ImageMediaFromJson(Map<String, dynamic> json) => $checkedCreate(
      'ImageMedia',
      json,
      ($checkedConvert) {
        final val = ImageMedia(
          id: $checkedConvert('media_id', (v) => v as String),
          url: $checkedConvert('url', (v) => v as String),
          blurHash: $checkedConvert('blur_hash', (v) => v as String?),
          type: $checkedConvert(
              'type', (v) => v as String? ?? ImageMedia.identifier),
        );
        return val;
      },
      fieldKeyMap: const {'id': 'media_id', 'blurHash': 'blur_hash'},
    );

Map<String, dynamic> _$ImageMediaToJson(ImageMedia instance) {
  final val = <String, dynamic>{
    'url': instance.url,
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('blur_hash', instance.blurHash);
  val['media_id'] = instance.id;
  return val;
}

MemoryImageMedia _$MemoryImageMediaFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MemoryImageMedia',
      json,
      ($checkedConvert) {
        final val = MemoryImageMedia(
          bytes: $checkedConvert(
              'bytes', (v) => const UintConverter().fromJson(v as List<int>)),
          id: $checkedConvert('id', (v) => v as String),
          url: $checkedConvert('url', (v) => v as String? ?? ''),
          type: $checkedConvert(
              'type', (v) => v as String? ?? MemoryImageMedia.identifier),
        );
        return val;
      },
    );

Map<String, dynamic> _$MemoryImageMediaToJson(MemoryImageMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'type': instance.type,
      'bytes': const UintConverter().toJson(instance.bytes),
    };
