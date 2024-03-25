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
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          media: $checkedConvert(
              'media',
              (v) => const ListMediaConverterFromRemoteConfig()
                  .fromJson(v as List)),
          caption: $checkedConvert('caption', (v) => v as String),
          likersInFollowings: $checkedConvert(
              'likers_in_followings',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) => User.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  const []),
          action: $checkedConvert(
              'action',
              (v) => const BlockActionConverter()
                  .fromJson(v as Map<String, dynamic>?)),
          type: $checkedConvert(
              'type', (v) => v as String? ?? PostLargeBlock.identifier),
        );
        return val;
      },
      fieldKeyMap: const {
        'createdAt': 'created_at',
        'likersInFollowings': 'likers_in_followings'
      },
    );

Map<String, dynamic> _$PostLargeBlockToJson(PostLargeBlock instance) {
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
  val['likers_in_followings'] =
      instance.likersInFollowings.map((e) => e.toJson()).toList();
  return val;
}
