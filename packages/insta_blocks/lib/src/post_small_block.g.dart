// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'post_small_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostSmallBlock _$PostSmallBlockFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PostSmallBlock',
      json,
      ($checkedConvert) {
        final val = PostSmallBlock(
          id: $checkedConvert('id', (v) => v as String),
          author: $checkedConvert(
              'author',
              (v) => const PostAuthorConverter()
                  .fromJson(v as Map<String, dynamic>)),
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          media: $checkedConvert(
              'media',
              (v) => const ListMediaConverterFromRemoteConfig()
                  .fromJson(v as List)),
          caption: $checkedConvert('caption', (v) => v as String),
          action: $checkedConvert(
              'action',
              (v) => const BlockActionConverter()
                  .fromJson(v as Map<String, dynamic>?)),
          type: $checkedConvert(
              'type', (v) => v as String? ?? PostSmallBlock.identifier),
        );
        return val;
      },
      fieldKeyMap: const {'createdAt': 'created_at'},
    );

Map<String, dynamic> _$PostSmallBlockToJson(PostSmallBlock instance) {
  final val = <String, dynamic>{
    'type': instance.type,
    'author': const PostAuthorConverter().toJson(instance.author),
    'id': instance.id,
    'created_at': instance.createdAt.toIso8601String(),
    'media': const ListMediaConverterFromRemoteConfig().toJson(instance.media),
    'caption': instance.caption,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('action', const BlockActionConverter().toJson(instance.action));
  return val;
}
