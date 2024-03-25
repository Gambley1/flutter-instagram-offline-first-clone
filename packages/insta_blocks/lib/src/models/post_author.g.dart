// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'post_author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostAuthor _$PostAuthorFromJson(Map<String, dynamic> json) => $checkedCreate(
      'PostAuthor',
      json,
      ($checkedConvert) {
        final val = PostAuthor(
          id: $checkedConvert('id', (v) => v as String),
          avatarUrl: $checkedConvert('avatar_url', (v) => v as String),
          username: $checkedConvert('username', (v) => v as String),
          isConfirmed:
              $checkedConvert('is_confirmed', (v) => v as bool? ?? false),
        );
        return val;
      },
      fieldKeyMap: const {
        'avatarUrl': 'avatar_url',
        'isConfirmed': 'is_confirmed'
      },
    );

Map<String, dynamic> _$PostAuthorToJson(PostAuthor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'is_confirmed': instance.isConfirmed,
    };
