// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'post_large_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostLargeBlock _$PostLargeBlockFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PostLargeBlock',
      json,
      ($checkedConvert) {
        final val = PostLargeBlock(
          id: $checkedConvert('id', (v) => v as String),
          author: $checkedConvert(
              'author',
              (v) => const PostAuthorConverter()
                  .fromJson(v as Map<String, dynamic>)),
          publishedAt: $checkedConvert(
              'published_at', (v) => DateTime.parse(v as String)),
          imageUrl: $checkedConvert('image_url', (v) => v as String),
          imagesUrl: $checkedConvert('images_url',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          caption: $checkedConvert('caption', (v) => v as String),
          action: $checkedConvert(
              'action',
              (v) => const BlockActionConverter()
                  .fromJson(v as Map<String, dynamic>?)),
          type: $checkedConvert(
              'type', (v) => v as String? ?? PostBlock.identifier),
        );
        return val;
      },
      fieldKeyMap: const {
        'publishedAt': 'published_at',
        'imageUrl': 'image_url',
        'imagesUrl': 'images_url'
      },
    );

Map<String, dynamic> _$PostLargeBlockToJson(PostLargeBlock instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'author': const PostAuthorConverter().toJson(instance.author),
    'published_at': instance.publishedAt.toIso8601String(),
    'image_url': instance.imageUrl,
    'images_url': instance.imagesUrl,
    'caption': instance.caption,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('action', const BlockActionConverter().toJson(instance.action));
  val['type'] = instance.type;
  return val;
}
