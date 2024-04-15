// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Post',
      json,
      ($checkedConvert) {
        final val = Post(
          id: $checkedConvert('id', (v) => v as String),
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          author: $checkedConvert('author',
              (v) => const UserConverter().fromJson(v as Map<String, dynamic>)),
          caption: $checkedConvert('caption', (v) => v as String),
          media: $checkedConvert(
              'media',
              (v) => v == null
                  ? const []
                  : const ListMediaConverterFromDb().fromJson(v as String)),
          updatedAt: $checkedConvert('updated_at',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {'createdAt': 'created_at', 'updatedAt': 'updated_at'},
    );

Map<String, dynamic> _$PostToJson(Post instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'author': const UserConverter().toJson(instance.author),
    'caption': instance.caption,
    'created_at': instance.createdAt.toIso8601String(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('updated_at', instance.updatedAt?.toIso8601String());
  val['media'] = const ListMediaConverterFromDb().toJson(instance.media);
  return val;
}
